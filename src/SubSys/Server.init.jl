# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# DefaultInit
function ObaServer_run_init!(onsetup::Function, vault_dir::AbstractString;
        # dev_mode = false # TODO: move to onsetup
        reset = true,
        source_config = true,
    )

    # empty server
    reset && emptystate!();
    
    # required initial stuff
    setstate!("Vault.root.path", abspath(vault_dir))
    setstate!("Callbacks.registry.functions", Dict{String, Vector{Function}}())
    setstate!("Callbacks.registry.priorities", Dict{String, Vector{Int}}())
    
    # source config
    source_config && source_configfile!()

    # register builtin
    _register_builtin_callbacks!()
    
    # direct onsetup
    onsetup()

    # run all callbacks
    run_callbacks!("Server.init.callbacks.onsetup")

    # final callback
    run_callbacks!("Server.init.callbacks.onsetup.ends")

    # akn flag
    setstate!("Server.init.flags.runned", true)

    return nothing

end
ObaServer_run_init!(vault_dir::AbstractString) = ObaServer_run_init!(_do_nothing, vault_dir)



