## ---.- .-  ..- .- . ... . - -. -.- .. .- . -.- .- .- 
# This is called at `run_init!`
# It will register all builtin callbacks
# This way the callbacks can be empty!ed at reset
BUILT_IN_PRIORITY = typemin(Int) ÷ 2

function _register_builtin_callbacks!()

    register_callback!(_Server_loop_onsetup_cb!, 
        "Server.setup.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_Callbacks_onsetup_cb!, 
        "Server.setup.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_Vault_onsetup_cb!, 
        "Server.setup.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_TriggerFile_onsetup_cb!, 
        "Server.setup.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    register_callback!(_Parser_onsetup_cb!, 
        "Server.setup.callbacks.onsetup", BUILT_IN_PRIORITY
    )
    
    register_callback!(_Vault_notes_onepass!, 
        "Server.loop.callbacks.oniter", BUILT_IN_PRIORITY
    )
    
    register_callback!(_Parser_onupdate!, 
        "Vault.callbacks.note.onupdate", BUILT_IN_PRIORITY
    )
    register_callback!(_Parser_run_onparsed_cb!, 
        "Vault.callbacks.notes.endpass", BUILT_IN_PRIORITY
    )
end
