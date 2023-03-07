

function VaultDir_init!(os::ObaServer;
        dir = pwd(),
        note_ext = ".md",
    )

    # data
    set!(os, :VaultDir, Dict())
    set!(os, [:VaultDir], "dir", dir)
    set!(os, [:VaultDir], "note_ext", note_ext)
    set!(os, [:VaultDir], "keepout", [".git", ".obsidian", ".trash"])
    set!(os, [:VaultDir], "notepaths_cache", Dict{String, String}())

end

export foreach_note
function foreach_note(f::Function, os::ObaServer)
    
    dir = get(os, [:VaultDir], "dir")
    note_ext = get(os, [:VaultDir], "note_ext")
    keepout = get(os, [:VaultDir], "keepout")
    return walkdown(dir; keepout) do file
        endswith(file, note_ext) || return false
        return f(file)
    end
end

export cached_notefile
function cached_notefile(os::ObaServer, name)
    name = basename(name)
    cache = get(os, [:VaultDir], "notepaths_cache")
    
    haskey(cache, name) && isfile(cache[name]) && return cache[name]

    file = findfirst_note(os, name)
    isnothing(file) && return nothing

    cache[name] = file
end

function findfirst_note(os::ObaServer, name)
    name = basename(name)
    file0 = nothing
    foreach_note(os) do file
        if basename(file) == name 
            file0 = file
            return true
        end
        return false
    end
    return file0
end

function _oba_plugin_trigger_file(os::ObaServer)
    dir = get(os, [:VaultDir], "dir")
    _oba_plugin_trigger_file(dir)
end

