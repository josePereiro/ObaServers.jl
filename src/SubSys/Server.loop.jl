# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# onsetup 
function _Server_loop_onsetup_cb!()
    # init defaults
    getstate!("Server.loop.trigger.hit.counter.max", typemax(Int))
    getstate!("Server.loop.trigger.miss.counter.max", typemax(Int))
    min_pulltime = getstate!("Server.loop.trigger.pulling.time.min", 0.5) # secs
    max_pulltime = getstate!("Server.loop.trigger.pulling.time.max", 5.0) # secs
    setstate!("Server.loop.trigger.pulling.SleepTimer", 
        SleepTimer(min_pulltime, max_pulltime, 0.01)
    )
    setstate!("Server.loop.flags.break", false)
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
function ObaServer_run_loop!(oniter::Function)

    
    !getstate("Server.init.flags.runned", false) && 
        error("Do `ObaServer_run_init!` first!")

    # counters
    iter_counter = 0
    hit_counter = 0
    miss_counter = 0
    tmr = getstate("Server.loop.trigger.pulling.SleepTimer")
    while !getstate(Bool, "Server.loop.flags.break")

        # loop delim
        println()
        println("-"^40)
        println()

        @show hit_counter

        while !getstate(Bool, "Server.loop.flags.break")

            run_callbacks!("Server.loop.callbacks.trigger.loop.init")
            
            # pull trigger
            if pull_trigger_file!()
                
                run_callbacks!("Server.loop.callbacks.trigger.onhit")
                
                # up counter
                hit_counter += 1
                setstate!("Server.loop.trigger.hit.counter", hit_counter)
                if hit_counter > getstate(Int, "Server.loop.trigger.hit.counter.max")
                    run_callbacks!("Server.loop.callbacks.trigger.hit.counter.onmax")
                    setstate!("Server.loop.flags.break", true)
                end
                
                reset!(tmr)
                break
            else
                run_callbacks!("Server.loop.callbacks.trigger.onmiss")

                # up counter
                miss_counter += 1
                setstate!("Server.loop.trigger.miss.counter", miss_counter)
                if miss_counter > getstate(Int, "Server.loop.trigger.miss.counter.max")
                    run_callbacks!("Server.loop.callbacks.trigger.miss.counter.onmax")
                    setstate!("Server.loop.flags.break", true)
                end
                
                sleep!(tmr)
            end
        end # trigger loop

        # loop body

        # check break
        getstate(Bool, "Server.loop.flags.break") && break

        # oniter direct call
        oniter()

        # oniter callbacks
        @time run_callbacks!("Server.loop.callbacks.oniter")

        # endloop callback
        run_callbacks!("Server.loop.callbacks.enditer")

        # oniter counter
        iter_counter += 1
        setstate!("Server.loop.trigger.iter.counter", iter_counter)

        # end delim
        println()

    end # server loop
    
    run_callbacks!("Server.loop.callbacks.break")

end
ObaServer_run_loop!() = ObaServer_run_loop!(_do_nothing)