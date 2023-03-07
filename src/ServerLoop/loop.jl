function ServerLoop_init!(os::ObaServer)

    # data
    set!(os, :ServerLoop, Dict())

    # callbacks
    register_callback!(os, (:Loop, :on_iter))
    register_callback!(os, (:Loop, :on_action_iter))
    register_callback!(os, (:Loop, :on_startup))
    
    register_callback!(os, (:Trigger, :on_miss_trigger, :server_loop))
    register_callback!(os, (:Trigger, :on_trigger, :server_loop))
    
    register_callback!(os, (:Loop, :on_iter), ObaServers, :_serverloop_on_iter_cb, -1000)
    register_callback!(os, (:Loop, :on_action_iter), ObaServers, :_serverloop_on_action_iter_cb, -1000)
    register_callback!(os, (:Loop, :on_startup), ObaServers, :_serverloop_touch_trigger_file, 0)
    register_callback!(os, (:ObaScripts, :on_ignored_file), ObaServers, :_serverloop_on_ignored_file_cb, -1000)
    register_callback!(os, (:Trigger, :on_trigger, :server_loop), ObaServers, :_serverloop_on_trigger_cb)
    register_callback!(os, (:Trigger, :on_miss_trigger, :server_loop), ObaServers, :_serverloop_miss_trigger_cb, 1000)

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

    run_callbacks(os, (:Loop, :on_startup), ())
    
    while true
        try
            run_callbacks(os, (:Loop, :on_iter), ())

            action_iter = get(os, [:ServerLoop], "action_iter")
                        
            # Trigger loop
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
                
                sync_trigger(os, (:server_loop,))

                # @show niters
                # @show trigger_iter
                
                # up iter
                set!(os, [:ServerLoop], "trigger_iter", trigger_iter + 1)
                

                # action
                is_action_iter = get(os, [:ServerLoop], "action_iter_flag", false)
                is_action_iter && break
            
            end # trigger loop

            t0 = now()
            
            # is_devmode(os) && @info("Action", action_iter = state["action_iter"])
        
            # on_trigger_iter
            run_callbacks(os, (:Loop, :on_action_iter), (action_iter,))

            # dev info
            is_devmode(os) && @info("Up action_iter_flag", 
                flag = get(os, [:ServerLoop], "action_iter_flag")
            )
            
            _info("Done", ""; 
                action_iter,
                time = ObaBase._canonicalize(now() - t0)
            )

            # up action iter
            set!(os, [:ServerLoop], "action_iter", action_iter + 1)

            # niter break
            action_iter >= niters && return os
        
        catch err
            (err isa InterruptException) && return os
            rethrow(err)
        end
    
    end # server loop

    return os

end

function run_server_loop(vault_dir::AbstractString;
        kwargs...
    )
    
    os = ObaServer(vault_dir)

    run_server_loop(os; kwargs...)

    return os
end