function _run_obascripts_cbs(os, call_key, action_iter)
    is_devmode(os) && @info(":_run_obascripts_cbs", call_key, action_iter)
    foreach_note(os) do notefile
        _run_notefile!(os, notefile)
        return false
    end
    return nothing
end

function _run_startup_round_cbs(os::ObaServer, call_key, args...)
    is_devmode(os) && @info(":_run_startup_round_cbs", call_key)
    
    _info("Start round", "=")
    
    # run startup.oba first
    name = startup_name(os)
    stfile = findfirst_note(os, name)
    @show stfile
    if !isnothing(stfile) && isfile(stfile)
        _run_notefile!(os::ObaServer, stfile)
    end

    # run the rest startup.oba first
    foreach_note(os) do notefile
        notefile != stfile && _run_notefile!(os, notefile)
        return false
    end
    
end