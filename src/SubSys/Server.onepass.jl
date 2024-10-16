# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
function run_onepass!(onsetup::Function, path::String; reinit = true)
    runned = getstate("Server.init.flags.runned", false)
    doinit = !runned || reinit
    doinit && run_init!(path) do
        # - .. - .- ..-. .-- - -.... . -- - .- - .-.- .- .-.
        # callbacks
        
        # touch_trigger_file()
        register_callback!("Server.loop.callbacks.trigger.loop.init") do
            touch_trigger_file() # force trigger
        end

        register_callback!("Server.loop.callbacks.enditer") do
            setstate!("Server.loop.flags.break", true)
        end
        
        # custom
        onsetup()
    end
    # reset pass
    setstate!("Server.loop.flags.break", false)
    # run
    run_loop!()
end