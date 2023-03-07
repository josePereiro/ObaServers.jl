## ------------------------------------------------------------------
# HEAD
function _handle_script_id_refactoring!(script_ast::ObaScriptBlockAST, mdfile)
    
    script_id = get_param(script_ast, "id", nothing)
    
    isnothing(script_id) || return false

    embtag = _generate_rand_id(string("L", script_ast.line))
    
    set_param!(script_ast, "id", embtag)

    # info
    _info("Refactoring source", "-"; 
        embtag, 
        mdfile = string(mdfile, ":", script_ast.line),
        newsrc = string("\n\n", script_ast.src),
    )

    write!!(script_ast)

    return true
end

## ------------------------------------------------------------------
# RUN SCRIPT

# This replace some util Base macros by its Oba equivalent globals.
# So the evaluation work similar to an included file
function _replace_base_macros(src)
    for (_macro, _global) in [
        ("__LINE__", "__LINE__"), 
        ("__FILE__", "__FILE__"), 
        ("__DIR__", "__DIR__"),
    ]
        src = replace(src, Regex(string("Base.@", _macro, "(?:\\(\\h*\\))?")) => _global)
        src = replace(src, Regex(string("@Base.", _macro, "(?:\\(\\h*\\))?")) => _global)
        src = replace(src, Regex(string("@", _macro, "(?:\\(\\h*\\))?")) => _global)
    end
    return src
end

export up_currscript!
"""
When a reparse! is made, new childs are created and the globals must be recomputed.
It assumes the id is unchanged.
"""

function _eval_obascript!(os::ObaServer, script_ast::ObaScriptBlockAST)
    
    # emb_script
    script_source = get(script_ast, :script, "")
    
    # reformat source
    script_source = _replace_base_macros(script_source)
    
    # handle scope (make local)
    if hasflag(script_ast, "l") || !(hasflag(script_ast, "s") || hasflag(script_ast, "g"))
        script_source = string("let;\n", strip(script_source), "\nend")
    end

    # info
    _info("Running ObaScriptBlockAST", "-"; 
        head = source(script_ast[:head]),
        notefile = string(curr_notefile(os), ":", curr_scripline(os)),
        obsidian = _obsidian_url(vault_dir(os), curr_notefile(os)),
        source = string("\n\n", script_source, "\n"), 
    )
    
    # eval
    # include_string(Main, script_source)
    expr = quote
        # globals
        __OS__ = $(os)
        __VAULT__ = $(vault_dir(os))
        __DIR__ = $(curr_notedir(os)) 
        __FILE__ = $(curr_notefile(os))
        __AST__ = $(curr_ast(os))
        __SCRIPT_AST__ = $(curr_scriptast(os))
        __SCRIPT_ID__ = $(curr_scriptid(os))
        __LINE__ = $(curr_scripline(os))
    end
    Main.eval(expr)
    include_string(Main, script_source)

end

function _run_notefile!(os::ObaServer, notefile::AbstractString)
    
    # init
    set!(os, [:ObaScripts], "processed_scripts_hashes", UInt64[])
    set!(os, [:ObaScripts], "per_files_iter", 1)
    
    # flags
    sync_files!(os, notefile)
    is_modified_notefile = on_flag!(os, (:FileTracker, :on_mtime_changed), "_run_notefile!", notefile)
    is_loop_startup = on_flag!(os, (:Loop, :on_startup), "_run_notefile!", notefile)

    while true
        
        # reset run again
        set!(os, [:ObaScripts], "run_again_signal", false)
        
        # parse
        AST = nothing
        try
            AST = noteast(os, notefile) # this call sync_file!

            # set global
            set!(os, [:ObaScripts], "curr_ast", AST)
            set!(os, [:ObaScripts], "curr_notefile", notefile)
            set!(os, [:ObaScripts], "curr_notedir", dirname(notefile))

        catch err
            _info("At Catch", ""; file = string(@__FILE__, ":", @__LINE__))
            rethrow(err)
        end

        # handle ignore file tags
        ignored_tag = nothing
        ignore_tags = get(os, [:ObaScripts], "ignore_tags", [])
        for toignore in ignore_tags
            if hastag(AST, toignore) 
                ignored_tag = toignore
                break
            end
        end
        if !isnothing(ignored_tag) 
            run_callbacks(os, (:ObaScripts, :on_ignored_file), (notefile, ignored_tag))
            return true
        end

        # before execution
        run_callbacks(os, (:ObaScripts, :before_exec), (notefile,))
        
        for child in AST
            
            # check type
            isscriptblock(child) || continue

            # dev info
            is_devmode(os) && _info("At Script", "="; 
                mdfile = string(notefile, ":", child.line),
                src = string("\n\n", child.src),
            )
            
            # set global
            set!(os, [:ObaScripts], "curr_scriptast", child)
            set!(os, [:ObaScripts], "curr_scripline", child.line)
            set!(os, [:ObaScripts], "curr_scriptid", get_param(child, "id"))
            
            # refactor if script_id is missing
            refactored = _handle_script_id_refactoring!(child, notefile)
            if refactored
                set!(os, [:ObaScripts], "run_again_signal", true)
                break # for child in AST 
            end

            # handle flags
            abort_flag = false

            # check if processed
            script_id = get_param(child, "id")
            hash_ = hash(script_id)
            processed = get(os, [:ObaScripts], "processed_scripts_hashes")
            was_processed = (hash_ in processed)
            !was_processed && push!(processed, hash_)
            abort_flag |= was_processed

            # startup
            is_at_startup_script = hasflag(child, "s")
            abort_flag |= is_loop_startup && !is_at_startup_script
            abort_flag |= !is_loop_startup && is_at_startup_script
            
            # on updated
            is_at_modified_script = hasflag(child, "u")
            abort_flag |= !is_modified_notefile && is_at_modified_script

            # ignore
            is_ignored_script = hasflag(child, "i") 
            abort_flag |= is_ignored_script

            is_devmode(os) && @info("Abort Flag", 
                is_at_startup_script, is_loop_startup, 
                is_at_modified_script, is_modified_notefile, 
                is_ignored_script, was_processed, abort_flag
            )
            
            abort_flag && continue

            # Run script
            try
                # run script
                _eval_obascript!(os, child)

                set!(os, [:ObaScripts], "run_again_signal", true)
                # because an script can modified its own file
                # I rerun the whole file 
                break # for child in AST

            catch err
                _info("At Catch", ""; file = string(@__FILE__, ":", @__LINE__))
                (err isa InterruptException) && return rethrow(err)
                _msg_error(os, "ERROR", err; 
                    notefile = string(notefile, ":", child.line), 
                    obsidian = string("[link](", _obsidian_url(os, notefile), ")" ),
                    src = string("\n\n", headless_source(child), "\n\n")
                )
                rethrow(err)
            end
        
        end # for child in AST

        run_again = get!(os, [:ObaScripts], "run_again_signal", false)
        if run_again
            is_devmode(os) && _info("Re-running","")
            run_callbacks(os, (:ObaScripts, :at_run_again), (notefile,))
        else
            # after execution
            is_devmode(os) && _info("End running","")
            run_callbacks(os, (:ObaScripts, :after_exec), (notefile,))
            break
        end

        iter_ = get(os, [:ObaScripts], "per_files_iter")
        niters_ = get!(os, [:ObaScripts], "per_files_niters", 1000)
        iter_ >= niters_ && break
        set!(os, [:ObaScripts], "per_files_iter", iter_ + 1)

    end # The run deep 

    return true

end

## ------------------------------------------------------------------
function startup_name(os::ObaServer) 
    note_ext = get(os, [:VaultDir], "note_ext")
    return string("startup.oba", note_ext)
end

