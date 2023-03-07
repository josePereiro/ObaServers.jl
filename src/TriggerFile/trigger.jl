_oba_plugin_trigger_file(vault::AbstractString) = joinpath(vault, ".obsidian", "plugins", "oba-plugin", "trigger-signal.json")

function TriggerFile_init!(os::ObaServer)
    
    # data
    set!(os, :TriggerFile, Dict())
    
    # file handler
    set!(os, [:TriggerFile], "path", _oba_plugin_trigger_file(os))
    set!(os, [:TriggerFile], "FileContentEvent", FileContentEvent())
    EasyEvents.update!(
        get(os, [:TriggerFile], "FileContentEvent"),
        get(os, [:TriggerFile], "path"),
    )

    # timer
    set!(os, [:TriggerFile], "SleepTimer", SleepTimer(0.5, 15.0, 0.01))

    # register callbacks
    register_callback!(os, (:Trigger, :on_trigger))
    register_callback!(os, (:Trigger, :on_miss_trigger))

end

## ------------------------------------------------------------------
# will trigger if the trigger_file changed
function sync_trigger(os::ObaServer, sub_calls...)
    handler = get(os, [:TriggerFile], "FileContentEvent")
    trfile = get(os, [:TriggerFile], "path")
    if has_event!(handler, trfile)
        event_group0 = (:Trigger, :on_trigger)
    else
        event_group0 = (:Trigger, :on_miss_trigger)
    end
    run_callbacks(os, event_group0, (), sub_calls...)
end

export touch_trigger_file
function touch_trigger_file(os::ObaServer)
    trfile = get(os, [:TriggerFile], "path")
    isempty(trfile) && return false
    isfile(trfile) || mkpath(dirname(trfile))
    write(trfile, _generate_rand_id(8))
    return true
end

