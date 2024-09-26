# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# Keys
# "Vault.root.path": root path od the vault
# "Vault.notes.ext": not files extenssions
# "Vault.walkdown.keepout": folders to keep out from parsing

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# oninit
function _Vault_onsetup_cb!()
    # println("Vault oninit!")

    # init defaults
    getstate!("Vault.notes.ext", ".md") 
    getstate!("Vault.walkdown.keepout", [".git", ".obsidian", ".trash"]) 
    getstate!("Vault.notes.paths.cache", Dict{String, String}()) # TODO: think about it
    setstate!("Vault.notes.FileMTimeEvent", FileMTimeEvent())
    setstate!("Vault.notes.modified", String[])
    setstate!("Vault.notes.news", String[])
    setstate!("Vault.notes.updates", String[])
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# define what is a note file
function is_notefile(path; note_ext = ".md")
    endswith(path, note_ext) || return false
end


# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
function foreach_note(f::Function)
    dir = getstate(String, "Vault.root.path")
    note_ext = getstate(String, "Vault.notes.ext")
    keepout = getstate(Vector{String}, "Vault.walkdown.keepout")
    return walkdown(dir; keepout) do file
        is_notefile(file; note_ext) || return false
        return f(file)
    end
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# TODO: Port to EasyEvent.jl
function _event_type!(evt::AbstractEvent, key)
    _isnew = !istraking(evt, key)
    if _isnew
        update!(evt, key)
        return :new
    end
    _ismod = pull_event!(evt, key)
    return _ismod ? :mod : :same
end


# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# Will be registrered at "Server.loop.callbacks.oniter"
# Visit all files and run callbacks depending on its modification state
function _Vault_notes_onepass!()

    fevt =  getstate(FileMTimeEvent, "Vault.notes.FileMTimeEvent")
    news_reg = getstate(Vector{String}, "Vault.notes.news")
    mod_reg = getstate(Vector{String}, "Vault.notes.modified")
    up_reg = getstate(Vector{String}, "Vault.notes.updates")

    empty!(news_reg)
    empty!(mod_reg)
    empty!(up_reg)
    foreach_note() do fn

        run_callbacks!("Vault.callbacks.note.foreach", fn)
        
        # parse if new or modified
        _etype = _event_type!(fevt, fn)
        _etype === :same && return
        if _etype === :new
            run_callbacks!("Vault.callbacks.note.onnew", fn)
            push!(news_reg, fn)
        end
        if _etype === :mod
            run_callbacks!("Vault.callbacks.note.onmod", fn)
            push!(mod_reg, fn)
        end
        run_callbacks!("Vault.callbacks.note.onupdate", fn)
        push!(up_reg, fn)
    end
    
    run_callbacks!("Vault.callbacks.notes.endpass")
    return 
end


# function cached_notefile(os::ObaServer, name)
#     name = basename(name)
#     cache = get(os, [:VaultDir], "notepaths_cache")
    
#     haskey(cache, name) && isfile(cache[name]) && return cache[name]

#     file = findfirst_note(os, name)
#     isnothing(file) && return nothing

#     cache[name] = file
# end

# function findfirst_note(os::ObaServer, name)
#     name = basename(name)
#     file0 = nothing
#     foreach_note(os) do file
#         if basename(file) == name 
#             file0 = file
#             return true
#         end
#         return false
#     end
#     return file0
# end
