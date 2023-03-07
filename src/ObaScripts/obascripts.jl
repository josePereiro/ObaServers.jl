function ObaScripts_init!(os::ObaServer)

    # data
    set!(os, :ObaScripts, Dict())
    
    # register callbacks
    register_callback!(os, (:ObaScripts, :before_exec))
    register_callback!(os, (:ObaScripts, :at_run_again))
    register_callback!(os, (:ObaScripts, :after_exec))
    register_callback!(os, (:ObaScripts, :on_ignored_file))
    register_callback!(os, (:Loop, :on_action_iter), ObaServers, :_run_obascripts_cbs, 0)
    register_callback!(os, (:Loop, :on_startup), ObaServers, :_run_startup_round_cbs, -1000)
    
end