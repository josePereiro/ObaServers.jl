function NotesASTs_init!(os::ObaServer)
    
    # data
    set!(os, :NotesASTs, Dict())
    set!(os, [:NotesASTs], "asts", Dict{AbstractString, ObaAST}())
    
    # callbacks
    register_callback!(os, (:NotesASTs, :on_parsed)) 
    register_callback!(os, (:FileTracker, :on_mtime_changed), ObaServers, :_parse_on_mtime_changed_cb)
    
end

function _parse_on_mtime_changed_cb(os, _, file)
    
    ast = parse_file(file)
    set!(os, [:NotesASTs, "asts"], file, ast)

    # on_parse
    run_callbacks(os, (:NotesASTs, :on_parsed), (file,))

    return nothing
end

export noteast
function noteast(os::ObaServer, name)
    file = cached_notefile(os, name)
    isnothing(file) && error("Note not found, name: ", name)
    sync_files!(os, file) # handle disk-cache synching
    return get!(os, [:NotesASTs, "asts"], file) do
        parse_file(file)
    end
end

export foreach_noteast
function foreach_noteast(f::Function, os::ObaServer)
    foreach_note(os) do file
        ast = noteast(os, file)
        return f(ast)
    end
end
