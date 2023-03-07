function _parse_on_mtime_changed_cb(os, _, file)
    
    delete!(os, [:NotesASTs, "asts"], file)
    ast = _parse_file(os, file)
    set!(os, [:NotesASTs, "asts"], file, ast)

    # on_parse
    run_callbacks(os, (:NotesASTs, :on_parsed), (file,))

    return nothing
end

function _parse_on_mtime_changed_cb(os, _, args...)
    sync_files!(os, notefile)
end
