# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# Keys

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# onsetup 
function _Server_loop_onsetup_cb!()
    # init defaults
    setstate!("Server.loop.counter", 0)
    getstate!("Server.loop.counter.max", typemax(Int))
    min_pulltime = getstate!("Server.loop.trigger.pulling.time.min", 0.5) # secs
    max_pulltime = getstate!("Server.loop.trigger.pulling.time.max", 5.0) # secs
    setstate!("Server.loop.trigger.pulling.SleepTimer", 
        SleepTimer(min_pulltime, max_pulltime, 0.01)
    )
    setstate!("Server.loop.flags.break", false)
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
function run_loop!(onloop::Function)

    
    # onsetup callbacks
    # run_callbacks!("Server.loop.callbacks.onsetup")

    loop_counter = 0
    tmr = getstate("Server.loop.trigger.pulling.SleepTimer")
    while !getstate(Bool, "Server.loop.flags.break")

        @show loop_counter
        while !getstate(Bool, "Server.loop.flags.break")
            # pull trigger
            if pull_trigger_file!()
                run_callbacks!("Server.loop.callbacks.trigger.hit")
                reset!(tmr)
                break
            else
                run_callbacks!("Server.loop.callbacks.trigger.miss")
                sleep!(tmr)
            end
        end

        # init delim
        println()
        println("-"^40)
        println()

        # onloop direct call
        onloop()

        # onloop callbacks
        @time run_callbacks!("Server.loop.callbacks.onloop")

        # up counter
        loop_counter += 1
        setstate!("Server.loop.counter", loop_counter)
        max_counter = getstate("Server.loop.counter.max")
        if loop_counter >= max_counter 
            run_callbacks!("Server.loop.callbacks.counter.max")
            setstate!("Server.loop.flags.break", true)
        end

        # endloop callback
        run_callbacks!("Server.loop.callbacks.endloop")

        # end delim
        println()

    end
    
    run_callbacks!("Server.loop.callbacks.atexit")

end
run_loop!() = run_loop!(_do_nothing)