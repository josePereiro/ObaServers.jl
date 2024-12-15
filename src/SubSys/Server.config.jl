# load config file
function configfile()
    root = getstate("Vault.root.path")
    cfile = joinpath(root, "ObaServer.json")
    try
        return _read_json(cfile)
        catch _; return Dict{String, Any}()
    end
end

# load config file and merge with state
function source_configfile!()
    config = configfile()
    for (k, v) in config
        setstate!(k, v)
    end
end

