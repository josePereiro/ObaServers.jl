function _serverloop_on_action_iter_cb(os::ObaServer, args...)
    _info("Boom!!! triggered", "")
    set!(os, [:ServerLoop], "action_iter_flag", false)
end

function _serverloop_on_iter_cb(os::ObaServer, args...)
    _info("Waiting for trigger", ".")
end

function _serverloop_on_ignored_file_cb(os::ObaServer, k, notefile, ignored_tag)
    _info("File ignored", "-"; notefile, ignored_tag)
end

function _serverloop_miss_trigger_cb(os::ObaServer, args...)
    timer::SleepTimer = get(os, [:TriggerFile], "SleepTimer")
    ObaBase.sleep!(timer)
end

function _serverloop_on_trigger_cb(os::ObaServer, args...)

    timer::SleepTimer = get(os, [:TriggerFile], "SleepTimer")
    ObaBase.reset!(timer)

    # signal action iter
    set!(os, [:ServerLoop], "action_iter_flag", true)

    is_devmode(os) && @info("Up action_iter_flag", 
        flag = get(os, [:ServerLoop], "action_iter_flag")
    )

    return nothing
end

_serverloop_touch_trigger_file(os::ObaServer, args...) =
    touch_trigger_file(os)
