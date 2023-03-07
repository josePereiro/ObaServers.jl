function _serverloop_startup_miss_trigger_cb(os::ObaServer, args...)
    timer::SleepTimer = get(os, [:TriggerFile], "SleepTimer")
    ObaBase.sleep!(timer)
end

function _serverloop_startup_on_trigger_cb(os::ObaServer, args...)
    
    timer::SleepTimer = get(os, [:TriggerFile], "SleepTimer")
    ObaBase.reset!(timer)

    _info("Boom!!! triggered", "")
end

function _serverloop_on_startup_cb(os::ObaServer, args...)
    set!(os, [:ServerLoop], "errorless_startup", true)
end

function _serverloop_startup_on_err_cb(os::ObaServer, args...)
    set!(os, [:ServerLoop], "errorless_startup", false)
    _info("Waiting for trigger", ".")
end

## ------------------------------------------------------------------
function _serverloop_before_action_iter_cb(os::ObaServer, args...)
    _info("Waiting for trigger", ".")
end

function _serverloop_iter_miss_trigger_cb(os::ObaServer, args...)
    timer::SleepTimer = get(os, [:TriggerFile], "SleepTimer")
    ObaBase.sleep!(timer)
end

function _serverloop_iter_on_trigger_cb(os::ObaServer, args...)
    timer::SleepTimer = get(os, [:TriggerFile], "SleepTimer")
    ObaBase.reset!(timer)
end

function _serverloop_iter_on_action_iter_cb(os::ObaServer, args...)
    _info("Boom!!! triggered", "")
end

## ------------------------------------------------------------------
function _serverloop_on_ignored_file_cb(os::ObaServer, k, notefile, ignored_tag)
    _info("File ignored", "-"; notefile, ignored_tag)
end
