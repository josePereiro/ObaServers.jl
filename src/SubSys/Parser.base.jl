# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# Keys
# "Parser.notes.asts": last version of parsed asts
# - Users are responsable of the maintenance of this regeistry
# - It will automatically update if a chenged is detected in 
# the sorce file or the entry is missing.

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# oninit
function _Parser_onsetup_cb!()
    # println("Parser oninit!")

    # init defaults
    setstate!("Parser.notes.asts", Dict{String, ObaAST}()) 
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# Will be registrered at "Server.loop.callbacks.oniter"
# Parse all modified/new files
function _Parser_onupdate!()
    asts_reg = getstate(Dict{String, ObaAST}, "Parser.notes.asts")
    fn = first(getstate("Callbacks.call.args"))
    # parse
    try
        ast = parse_file(fn)
        asts_reg[fn] = ast
        run_callbacks!("Parser.callbacks.note.onparsed", fn, ast)
    catch err
        # TODO: handle error
        @error("PARSING ERROR", err, fn)
        run_callbacks!("Parser.callbacks.note.onerror", fn)
        # rethrow(err)
    end
    return 
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
_Parser_run_onparsed_cb!() = run_callbacks!("Parser.callbacks.vault.onparsed")

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# /Users/Pereiro/Documents/Obsidian/notebook/2_notes/@mezardInformationPhysicsComputation2009.md
function noteast(name)
    fn = isabspath(name) ? name : joinpath(getstate("Vault.root.path"), name)
    asts_reg = getstate(Dict{String, ObaAST}, "Parser.notes.asts")
    return asts_reg[fn]
end

# # -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# function NotesASTs_init!(os::ObaServer)
    
#     # data
#     set!(os, :NotesASTs, Dict())
#     set!(os, [:NotesASTs], "asts", Dict{AbstractString, ObaAST}())
    
#     # callbacks
#     register_callback!(os, (:NotesASTs, :on_parsed)) 
#     register_callback!(os, 
#         (:FileTracker, :on_content_changed, :NotesASTs), 
#         ObaServers, :_parse_note_content_changed_cb
#     )
    
# end

# function _parse_file(os::ObaServer, notefile)
#     try
#         return parse_file(notefile)
#     catch err
#         _info("At Catch", ""; file = string(@__FILE__, ":", @__LINE__))
#         (err isa InterruptException) && return rethrow(err)
#         _msg_error(os, "PARSING ERROR", err; 
#             notefile, 
#             obsidian = string("[link](", _obsidian_url(os, notefile), ")" ),
#         )
#         rethrow(err)
#     end
# end

# export noteast
# function noteast(os::ObaServer, name)

#     file = cached_notefile(os, name)
#     isnothing(file) && error("Note not found, name: ", name)
    
#     # handle disk-cache synching
#     sync_files!(os, file, (:NotesASTs,)) 

#     # handle first time
#     asts = get(os, [:NotesASTs], "asts")
#     if !haskey(asts, file)
#         asts[file] = _parse_file(os, file)
#     end
    
#     return asts[file]
# end

# export foreach_noteast
# function foreach_noteast(f::Function, os::ObaServer)
#     foreach_note(os) do file
#         ast = noteast(os, file)
#         return f(ast)
#     end
# end
