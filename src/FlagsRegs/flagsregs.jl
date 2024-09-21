function FlagsRegs_init!(os::ObaServer)
    
    # data
    set!(os, :FlagsRegs, Dict())
    set!(os, [:FlagsRegs], "call-level", Dict())
    set!(os, [:FlagsRegs], "arg-level", Dict())

end

# --------------------------------------------------------------------
# top_registry (:FlagsRegs)
#    |- "call-level-flags"
#         |- call_key
#                |- flag_key
#                   |- flag ∈ [true, false]
#    |- arg_registry (call_key) => Dict
#         |- call_key
#           |- arg_registry
#               |- args
#                   |- flag_key
#                       |- flag ∈ [true, false]

# --------------------------------------------------------------------
# onflag function 
_ret_true() = true

# top_registry (:FlagsRegs)
#    |- "call-level-flags"
#         |- call_key
#                |- flag_key
#                   |- flag ∈ [true, false]

export on_flag!
function on_flag!(f::Function, os::ObaServer, call_key::Tuple, flag_key)
    # call-level-flags
    reg0 = get(os, [:FlagsRegs], "call-level")
    reg1 = get!(reg0, call_key, Dict())
    
    flag = get(reg1, flag_key, true)
    reg1[flag_key] = false # consumes flag
    
    flag === true || return false

    return f()
end

function on_flag!(f::Function, os::ObaServer, call_key::Tuple, flag_key, args...)
    # arg-level-flags
    reg0 = get(os, [:FlagsRegs], "arg-level")
    reg1 = get!(reg0, call_key, Dict())
    reg2 = get!(reg1, args, Dict())

    flag = get(reg2, flag_key, true)
    reg2[flag_key] = false # consumes flag
    
    flag === true || return false

    return f()
end

export has_true_flag!
has_true_flag!(os::ObaServer, call_key::Tuple, key_and_args...) =
    on_flag!(_ret_true, os, call_key, key_and_args...)

# --------------------------------------------------------------------

# Informe all valid flags that call_key event happends with the given arguments
function _FlagsRegs_flipflags_cbs(os, call_key, args...)

    # call-level-flags
    reg0 = get(os, [:FlagsRegs], "call-level")
    reg1 = get!(reg0, call_key, Dict())
    for flag_key in keys(reg1)
        reg1[flag_key] = true
    end

    # args-level-flags
    reg0 = get(os, [:FlagsRegs], "arg-level")
    reg1 = get!(reg0, call_key, Dict())
    reg2 = get(reg1, args, nothing)
    isnothing(reg2) && return
    for flag_key in keys(reg2)
        reg2[flag_key] = true
    end

end