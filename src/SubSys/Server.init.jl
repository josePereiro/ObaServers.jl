# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
# DefaultInit
function run_init!(onsetup::Function, vault_dir::AbstractString;
        # dev_mode = false # TODO: move to onsetup
    )

    # empty server
    emptystate!();
    
    # required initial states
    setstate!("Vault.root.path", abspath(vault_dir))
    setstate!("Callbacks.registry.functions", Dict{String, Vector{Function}}())
    setstate!("Callbacks.registry.priorities", Dict{String, Vector{Int}}())
    
    # source config
    source_configfile!()

    # direct onsetup
    onsetup()

    # register builtin
    _register_builtin_callbacks!()
    
    # run all callbacks
    run_callbacks!("Server.setup.callbacks.onsetup")

end
run_init!(vault_dir::AbstractString) = run_init!(_do_nothing, vault_dir)



