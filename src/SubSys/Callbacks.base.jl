## ---.- .- ..- .- . ... . - -. -.- .. .- . -.- .- .- 
# Keys
# "Callbacks.registry.functions"
# "Callbacks.registry.priorities"

## ---.- .- ..- .- . ... . - -. -.- .. .- . -.- .- .- 
# Each callback will have a key::String
# Registry:
# - You can defined a priority of execution
# Run:
# - At call all registered callbacks will be executed
# - Any arguments needed for the call back will be stored at 
# get(os, "Callbacks.call.args") as a Tuple

## ---.- .-  ..- .- . ... . - -. -.- .. .- . -.- .- .- 
# onsetup
function _Callbacks_onsetup_cb!()
    nothing
end

callback_functions() = getstate(Dict{String, Vector{Function}}, "Callbacks.registry.functions")
callback_priorities() = getstate(Dict{String, Vector{Int}}, "Callbacks.registry.priorities")

## ---.- .- ..- .- . ... . - -. -.- .. .- . -.- .- .- 
function register_callback!(cb::Function, key::String, priority = 0)
    
    funvec = get!(callback_functions(), key, Function[])
    push!(funvec, cb)

    priorvec = get!(callback_priorities(), key, Int[]) 
    push!(priorvec, priority)

    # sort
    I = sortperm(priorvec)
    permute!(funvec, I)
    permute!(priorvec, I)
    
    return 
end

## ---.- .- ..- .- . ... . - -. -.- .. .- . -.- .- .- 
function run_callbacks!(key::String, args...)
    
    # Update state
    setstate!("Callbacks.call.key", key)
    setstate!("Callbacks.call.args", args)

    callfuns = callback_functions()
    funvec = get!(Vector{Function}, callfuns, key)
    for fun in funvec
        ret = fun()
        ret === :break && break
    end

    return
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
function emptycallbacks!()
    empty!(callback_functions())
    empty!(callback_priorities())
end

# -.-. -. -- - . - . . .- --. -. -.-. -.----- . .. .
function show_callbacks()
    _callfuns = callback_functions()
    _keys = collect(keys(_callfuns))
    sort!(_keys)
    for k in _keys
        v = _callfuns[k]
        printstyled(repr(k); color = :blue)
        print(" -> ")
        v = join(map(repr, v), ", ")
        printstyled("[", v, "]"; color = :green)
        println()
    end
end