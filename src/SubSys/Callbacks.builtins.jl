## ---.- .-  ..- .- . ... . - -. -.- .. .- . -.- .- .- 
# This is called at `ObaServer_run_init!`
# It will register all builtin callbacks
# This way the callbacks can be empty!ed at reset
const BUILT_IN_PRIORITY = typemin(Int) ÷ 2

function _register_builtin_callbacks!()

    # "Server.init.callbacks.onsetup"
    register_callback!(_Server_loop_onsetup_cb!, 
        "Server.init.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_Callbacks_onsetup_cb!, 
        "Server.init.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_Vault_onsetup_cb!, 
        "Server.init.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_TriggerFile_onsetup_cb!, 
        "Server.init.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_Parser_onsetup_cb!, 
        "Server.init.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    
    # "Server.loop.callbacks.oniter"
    register_callback!(_Vault_notes_onepass_cb!, 
        "Server.loop.callbacks.oniter", BUILT_IN_PRIORITY
    )
    
    # "Vault.callbacks.note.onupdate"
    register_callback!(_Parser_onupdate_cb!, 
        "Vault.callbacks.note.onupdate", BUILT_IN_PRIORITY
    )
    register_callback!(_Parser_run_onparsed_cb!, 
        "Vault.callbacks.notes.endpass", BUILT_IN_PRIORITY
    )

    # "Server.loop.callbacks.trigger.onhit"
    register_callback!(_Vault_onhit_cb!, 
        "Server.loop.callbacks.trigger.onhit", 
        BUILT_IN_PRIORITY
    )
end
