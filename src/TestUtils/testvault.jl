export create_testvault
function create_testvault(vault_dir::AbstractString; kwargs...)
    isdir(vault_dir) || mkpath(vault_dir)
    isempty(readdir(vault_dir)) || error("vault_dir is not empty, vault_dir: ", vault_dir)
    
    store_dir = joinpath(pkgdir(ObaServers), "testvault")
    cp(store_dir, vault_dir; force = true)

    os = ObaServer(vault_dir; kwargs...)
    touch_trigger_file(os)
    
    return os
end