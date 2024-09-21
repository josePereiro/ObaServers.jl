## ------------------------------------------------------------------
# globals
export vault_dir
vault_dir(os::ObaServer) = get(os, [:VaultDir], "dir", nothing)

export curr_notefile
curr_notefile(os::ObaServer) = get(os, [:ObaScripts], "curr_notefile", nothing)

export curr_ast
function curr_ast(os::ObaServer) 
    notefile = curr_notefile(os)
    isnothing(notefile) && return nothing
    return noteast(os, notefile)
end

export curr_notedir
function curr_notedir(os::ObaServer)
    ast = curr_ast(os)
    isnothing(ast) && return nothing
    return dirname(ast.file)
end

export curr_scriptid
curr_scriptid(os::ObaServer) = get(os, [:ObaScripts], "curr_scrip_id", nothing)

export curr_scriptast
function curr_scriptast(os::ObaServer) 
    ast = curr_ast(os)
    isnothing(ast) && return nothing
    id = curr_scriptid(os)
    isnothing(id) && return nothing
    idx = ObaASTs.find_byid(ast, id)
    isnothing(idx) && return nothing
    return ast[idx]
end

# Use file and id as globals to ensure syncing
export curr_scriptline
function curr_scriptline(os::ObaServer)
    src = curr_scriptast(os)
    isnothing(src) && return nothing
    return src.line
end

