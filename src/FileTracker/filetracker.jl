function FileTracker_init!(os::ObaServer)

    # data
    set!(os, :FileTracker, Dict())
    set!(os, [:FileTracker], "FileContentEvent", FileContentEvent())
    set!(os, [:FileTracker], "FileMTimeEvent", FileMTimeEvent())
    set!(os, [:FileTracker], "FileSizeEvent", FileSizeEvent())

    # register FileTracker global callbacks
    register_callback!(os, (:FileTracker, :on_mtime_changed)) 
    register_callback!(os, (:FileTracker, :on_size_changed)) 
    register_callback!(os, (:FileTracker, :on_content_changed))

    # sync_notes!(os)

    return os
end

# Warranty that the callbacks to sync the files are called
# if necessary
function _sync_file!(os::ObaServer, file::AbstractString, sub_calls::Tuple...)

    # @info("_sync_file!", file, sub_calls)

    # on_content_changed
    handler = get(os, [:FileTracker], "FileContentEvent")
    if has_event!(handler, file) 
        event_group0 = (:FileTracker, :on_content_changed)
        # @show event_group0
        run_callbacks(os, event_group0, (file,), sub_calls...)
    end
    
    # on_mtime_changed
    handler = get(os, [:FileTracker], "FileMTimeEvent")
    if has_event!(handler, file) 
        event_group0 = (:FileTracker, :on_mtime_changed)
        # @show event_group0
        run_callbacks(os, event_group0, (file,), sub_calls...)
    end

    # on_size_changed
    handler = get(os, [:FileTracker], "FileSizeEvent")
    if has_event!(handler, file) 
        event_group0 = (:FileTracker, :on_size_changed)
        # @show event_group0
        run_callbacks(os, event_group0, (file,), sub_calls...)
    end

end

export sync_files!
function sync_files!(os::ObaServer, files::Vector, sub_calls::Tuple...)
    for file in files
        _sync_file!(os, file, sub_calls...)
    end
end
sync_files!(os::ObaServer, file::AbstractString, sub_calls::Tuple...) = 
    _sync_file!(os, file, sub_calls...)

export sync_notes!
function sync_notes!(os, sub_calls...)
    foreach_note(os) do file
        _sync_file!(os, file, sub_calls...)
    end
end