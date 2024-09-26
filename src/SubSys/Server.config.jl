# load config file
function source_configfile!()
    root = getstate("Vault.root.path")
    cfile = joinpath(root, "ObaServer.json")
    isfile(cfile) || return
    config = _read_json(cfile)
    for (k, v) in config
        setstate!(k, v)
    end
end