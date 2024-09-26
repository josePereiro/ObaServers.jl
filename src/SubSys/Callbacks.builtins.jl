## ---.- .-  ..- .- . ... . - -. -.- .. .- . -.- .- .- 
# This is called at `run_init!`
# It will register all builtin callbacks
# This way the callbacks can be empty!ed at reset
function _register_builtin_callbacks!()

    register_callback!(_Server_loop_onsetup_cb!, "Server.setup.callbacks.onsetup", typemin(Int))
    register_callback!(_Callbacks_onsetup_cb!, "Server.setup.callbacks.onsetup", typemin(Int))
    register_callback!(_Vault_onsetup_cb!, "Server.setup.callbacks.onsetup", typemin(Int))
    register_callback!(_TriggerFile_onsetup_cb!, "Server.setup.callbacks.onsetup", typemin(Int))
    register_callback!(_Parser_onsetup_cb!, "Server.setup.callbacks.onsetup", typemin(Int))
    
    register_callback!(_Vault_notes_onepass!, "Server.loop.callbacks.onloop", typemin(Int))
    register_callback!(_Parser_onupdate!, "Vault.callbacks.note.onupdate", typemin(Int))

    register_callback!("Vault.callbacks.notes.endpass") do
        run_callbacks!("Parser.callbacks.vault.endparse")
    end
end
