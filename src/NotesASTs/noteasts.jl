function NotesASTs_init!(os::ObaServer)
    
    # data
    set!(os, :NotesASTs, Dict())
    set!(os, [:NotesASTs], "asts", Dict{AbstractString, ObaAST}())
    
    # callbacks
    register_callback!(os, (:NotesASTs, :on_parsed)) 
    register_callback!(os, (:FileTracker, :on_mtime_changed), ObaServers, :_parse_on_mtime_changed_cb)
    
end

function _parse_file(os::ObaServer, notefile)
    try
        return parse_file(notefile)
    catch err
        _info("At Catch", ""; file = string(@__FILE__, ":", @__LINE__))
        (err isa InterruptException) && return rethrow(err)
        _msg_error(os, "PARSING ERROR", err; 
            notefile, 
            obsidian = string("[link](", _obsidian_url(os, notefile), ")" ),
        )
        rethrow(err)
    end
end

export noteast
function noteast(os::ObaServer, name)

    file = cached_notefile(os, name)
    isnothing(file) && error("Note not found, name: ", name)
    
    # handle disk-cache synching
    sync_files!(os, file) 

    # handle first time
    if !haskey(os, [:NotesASTs, "asts"], file)
        ast = _parse_file(os, file)
        set!(os, [:NotesASTs, "asts"], file, ast)
    end
    
    return get(os, [:NotesASTs, "asts"], file) 
end

export foreach_noteast
function foreach_noteast(f::Function, os::ObaServer)
    foreach_note(os) do file
        ast = noteast(os, file)
        return f(ast)
    end
end
