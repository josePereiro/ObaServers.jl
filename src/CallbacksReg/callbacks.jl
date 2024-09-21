# CALLBACK INTERFACE
# A registry of functions to be called on a given events
# IMPORTANT: the callback calling must be implemented on a way that do not trigger
# the event again (for performance and to avoid infty loops)
# See FileTracker/sync_files as an example

export callback_registry
function callback_registry(os::ObaServer)
    cbreg = get!(os, :CallbacksReg, Dict())
    return get!(cbreg, "reg") do 
        Dict{Tuple, OrderedSet{Tuple{Int, Module, Symbol}}}()
    end
end
function callback_registry(os::ObaServer, key)
    cbreg = callback_registry(os)
    return get!(cbreg, key) do 
        _warn("WARNNING: Callback group not registred", "?"; key)
        OrderedSet{Tuple{Int, Module, Symbol}}()
    end
end

export callbacks_list
function callbacks_list(os::ObaServer; all = false)
    cbreg = callback_registry(os)
    for (id, calls) in cbreg
        all || isempty(calls) && continue
        println(rpad(string("On ", id, " "), 60, "-"))
        for (p, mod, call) in calls
            println(" ->  ", mod, ".", call, " [", p, "]")
        end
    end
end

function _register_callback!(os::ObaServer, call_key)
    cbreg = callback_registry(os)
    callbacks = get!(cbreg, call_key, OrderedSet{Tuple{Int, Module, Symbol}}())
    return cbreg, callbacks
end

export register_callback!
register_callback!(os::ObaServer, call_key) = (_register_callback!(os::ObaServer, call_key); nothing)

"""
    register_callback!(f::Symbol, os::ObaServer, key = :on_modified)

Register a function `f(ast)` to be called every `key` event happends.
The functions are responsable for calling reparse!/write!! to validate the ast.
The user must handle duplication avoidance.
For see all events explore `callback_registry()` keys
"""
function register_callback!(os::ObaServer, call_key, mod::Module, fname::Symbol, p::Int = 20)
    cbreg, callbacks = _register_callback!(os, call_key)
    
    # Add flag registry callback
    isempty(callbacks) && push!(callbacks, (-10000, ObaServers, :_FlagsRegs_flipflags_cbs))
    
    # Add costum
    push!(callbacks, (p, mod, fname))
    
    # sort callbacks by p
    sorted_calls = sort(collect(callbacks); by = first)
    cbreg[call_key] = OrderedSet(sorted_calls)

    return nothing
end

register_callback!(os::ObaServer, call_key, fname::Symbol, p::Int = 20) = 
    register_callback!(os, call_key, Main, fname, p)

function _run_callbacks(os::ObaServer, call_key, args::Tuple)

    dry_run = get!(os, [:CallbacksReg], "dry_run", false)

    calls = callback_registry(os, call_key)
    isempty(calls) && return

    for (p, mod, fname) in calls
        fun = getfield(mod, fname)
        is_devmode(os) && @info("Running callback", 
            call_key, mod, fname, args
        )
        # TODO: do this with regular invoking
        if dry_run; _info("Callback (dry run)", ""; call_key, mod, fname, args)
            else; Base.invokelatest(fun, os, call_key, args...)
        end
    end
end

function run_callbacks(os::ObaServer, call_key0, args::Tuple, sub_calls...)
    
    _run_callbacks(os, call_key0, args)

    for sub_call in sub_calls
        call_key = _concat(call_key0, sub_call)
        _run_callbacks(os, call_key, args)
    end
end