# This needs to be in sync with the interface defined at
# oba-plugin/src/backends.ts

# TODO reneame to oba.backends interface
# - trigger file is not general enought 

## .--- .- .- .--. ..- .- -.-. ...  . -- - -- 
# sync with: oba.backends.getHashSignalPath
_oba_hash_signal_file(vault::AbstractString) =
    joinpath(vault, ".Oba", "backends", "hash-signal.json")

# sync with: oba.backends.getStateSignalPath
_oba_state_signal_file(vault::AbstractString) =
    joinpath(vault, ".Oba", "backends", "state-signal.json")

# _oba_plugin_trigger_file(vault::AbstractString) = 
#     joinpath(vault, ".obsidian", "plugins", "oba-plugin", "backend-signal.json")

## .--- .- .- .--. ..- .- -.-. ...  . -- - -- 
function _TriggerFile_onsetup_cb!()
    # file handler
    _vtpath = getstate("Vault.root.path")
    _trfile = getstate!("TriggerFile.hash.signal.path", _oba_hash_signal_file(_vtpath))
    _trfile = getstate!("TriggerFile.state.path", _oba_state_signal_file(_vtpath))
    _fce = getstate!("TriggerFile.FileContentEvent", FileContentEvent())
    EasyEvents.update!(_fce, _trfile)
end

## .--- .- .- .--. ..- .- -.-. ...  . -- - -- 
# Check if trigger file changed
function pull_trigger_file!()
    _handler = getstate("TriggerFile.FileContentEvent")
    _trfile = getstate("TriggerFile.hash.signal.path")
    return pull_event!(_handler, _trfile)
end

# # will trigger if the trigger_file changed
# function sync_trigger(os::ObaServer, sub_calls...)
#     handler = get(os, [:TriggerFile], "FileContentEvent")
#     trfile = get(os, [:TriggerFile], "path")
#     if has_event!(handler, trfile)
#         event_group0 = (:Trigger, :on_trigger)
#     else
#         event_group0 = (:Trigger, :on_miss_trigger)
#     end
#     run_callbacks(os, event_group0, (), sub_calls...)
# end

## .--- .- .- .--. ..- .- -.-. ...  . -- - -- 
# TOSYNC with oba-plugin code

# fake a trigger update
function touch_trigger_file()
    _trfile = getstate("TriggerFile.hash.signal.path")
    isempty(_trfile) && return false
    mkpath(dirname(_trfile))
    _write_json(_trfile, Dict(
        "signal.hash" => _generate_rand_id("T.", 16), 
    ))
    return true
end

## .--- .- .- .--. ..- .- -.-. ...  . -- - -- 
function oba_backends_state_json()
    _trfile = getstate("TriggerFile.state.path")
    return _read_json(_trfile)
end

## .--- .- .- .--. ..- .- -.-. ...  . -- - -- 