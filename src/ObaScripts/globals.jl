## ------------------------------------------------------------------
# globals
export vault_dir
vault_dir(os::ObaServer) = get(os, [:VaultDir], "dir", nothing)
export curr_notedir
curr_notedir(os::ObaServer) = get(os, [:ObaScripts], "curr_notedir", nothing)
export curr_notefile
curr_notefile(os::ObaServer) = get(os, [:ObaScripts], "curr_notefile", nothing)
export curr_ast
curr_ast(os::ObaServer) = get(os, [:ObaScripts], "curr_ast", nothing)
export curr_scriptast
curr_scriptast(os::ObaServer) = get(os, [:ObaScripts], "curr_scriptast", nothing)
curr_scriptid(os::ObaServer) = get(os, [:ObaScripts], "curr_scriptid", nothing)
export curr_scripline
curr_scripline(os::ObaServer) = get(os, [:ObaScripts], "curr_scripline", nothing)

# TODO: check is this is required
# function currscript() 
#     script_ast = getstate(CURRSCRIPT_GLOBAL_KEY)
#     ast = parent_ast(script_ast)
#     # check reparse counter
#     ast_counter = reparse_counter(ast)
#     last_counter = getstate!(CURRAST_REPARSE_COUNTER_GLOBAL_KEY, -1)
#     if ast_counter != last_counter
#         upstate!(CURRAST_REPARSE_COUNTER_GLOBAL_KEY, ast_counter)
#         script_ast = up_currscript!()
#     end
#     return script_ast
# end
