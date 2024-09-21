function ServerLoop_init!(os::ObaServer)

    # data
    set!(os, :ServerLoop, Dict())

    # callbacks
    register_callback!(os, (:Loop, :before_action_iter))
    register_callback!(os, (:Loop, :on_action_iter))
    register_callback!(os, (:Loop, :on_startup))
    register_callback!(os, (:Loop, :on_action_err))
    register_callback!(os, (:Loop, :on_startup_err))
    
    register_callback!(os, (:Trigger, :on_miss_trigger, :server_action_loop))
    register_callback!(os, (:Trigger, :on_miss_trigger, :server_startup_loop))
    register_callback!(os, (:Trigger, :on_trigger, :server_action_loop))
    register_callback!(os, (:Trigger, :on_trigger, :server_startup_loop))
    
    # startup loop
    register_callback!(os, (:Loop, :on_startup), ObaServers, :_serverloop_on_startup_cb, -10000)
    register_callback!(os, (:Loop, :on_startup_err), ObaServers, :_serverloop_startup_on_err_cb, -1000)
    register_callback!(os, (:Trigger, :on_trigger, :server_startup_loop), ObaServers, :_serverloop_startup_on_trigger_cb)
    register_callback!(os, (:Trigger, :on_miss_trigger, :server_startup_loop), ObaServers, :_serverloop_startup_miss_trigger_cb, 1000)
    
    # action loop
    register_callback!(os, (:Trigger, :on_trigger, :server_action_loop), ObaServers, :_serverloop_iter_on_trigger_cb)
    register_callback!(os, (:Trigger, :on_miss_trigger, :server_action_loop), ObaServers, :_serverloop_iter_miss_trigger_cb, 1000)
    register_callback!(os, (:Loop, :before_action_iter), ObaServers, :_serverloop_before_action_iter_cb, -1000)
    register_callback!(os, (:Loop, :on_action_iter), ObaServers, :_serverloop_iter_on_action_iter_cb, -1000)
    
    # general
    register_callback!(os, (:ObaScripts, :on_ignored_file), ObaServers, :_serverloop_on_ignored_file_cb, -1000)
    
    return nothing
end

export run_server_loop
function run_server_loop(os::ObaServer; 
        niters = typemax(Int), 
        force_trigger = false
    )

    # init
    set!(os, [:ServerLoop], "action_iter", 1)
    set!(os, [:ServerLoop], "trigger_iter", 1)
    set!(os, [:ServerLoop], "niters", niters)

    # ------------------------------------------------------------
    # Startup loop
    while true
        
        try
            set!(os, [:ServerLoop], "errorless_startup", false)

            # run on action callbacks
            t0 = now()
            
            # Run on on_startup callback
            run_callbacks(os, (:Loop, :on_startup), ())

            # TODO: move to callback
            _info("Done", ""; 
                time = ObaBase._canonicalize(now() - t0)
            )
            
            set!(os, [:ServerLoop], "errorless_startup", true)
            
        catch err

            _info("At catch", ""; file = string(@__FILE__, ":", @__LINE__))

            rethrow(err)
            
            # on_startup_err
            run_callbacks(os, (:Loop, :on_startup_err), ())

            (err isa InterruptException) && return os

            # wait for trigger
            while true

                sync_trigger(os, (:server_startup_loop,))

                is_triggered = has_true_flag!(os, 
                    (:Trigger, :on_trigger, :server_startup_loop), 
                    ("run_server_loop", "startup")
                )
                is_triggered && break
                
            end
    
        end

        # triggered 
        errorless_startup = get(os, [:ServerLoop], "errorless_startup", false)
        errorless_startup && break

    end # Startup loop

    # ------------------------------------------------------------
    # Action loop
    while true
        
        try

            run_callbacks(os, (:Loop, :before_action_iter), ())

            action_iter = get(os, [:ServerLoop], "action_iter")
                        
            # Wait for trigger
            while true

                # iters
                trigger_iter = get(os, [:ServerLoop], "trigger_iter")

                # trigger
                force_trigger && touch_trigger_file(os)
                trigger_iter == 1 && touch_trigger_file(os)

                # TODO: include on info
                trfile = get(os, [:TriggerFile], "path")
                is_devmode(os) && @info("Trigger", 
                    hash = isfile(trfile) ? read(trfile, String) : ""
                )
                
                # up iter
                set!(os, [:ServerLoop], "trigger_iter", trigger_iter + 1)
                
                # wait for iter
                sync_trigger(os, (:server_action_loop,))

                is_triggered = has_true_flag!(os, 
                    (:Trigger, :on_trigger, :server_action_loop), 
                    ("run_server_loop", "action_loop")
                )
                is_triggered && break
                
            
            end # trigger loop

            # run on action callbacks
            t0 = now()
        
            # on_trigger_iter
            run_callbacks(os, (:Loop, :on_action_iter), (action_iter,))
            
            # TODO: move to callback
            _info("Done", ""; 
                action_iter,
                time = ObaBase._canonicalize(now() - t0)
            )

            # up action iter
            set!(os, [:ServerLoop], "action_iter", action_iter + 1)

            # niter break
            action_iter >= niters && return os
        
        catch err
            _info("At Catch", ""; file = string(@__FILE__, ":", @__LINE__))
            rethrow(err)
            
            # on_startup_err
            run_callbacks(os, (:Loop, :on_action_err), ())
            
            (err isa InterruptException) && return os
        end
    
    end # Action loop

    return os

end

function run_server_loop(vault_dir::AbstractString;
        kwargs...
    )
    
    os = ObaServer(vault_dir)

    run_server_loop(os; kwargs...)

    return os
end