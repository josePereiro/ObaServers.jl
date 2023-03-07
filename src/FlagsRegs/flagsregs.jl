function FlagsRegs_init!(os::ObaServer)
    
    # data
    set!(os, :FlagsRegs, Dict())

end

# --------------------------------------------------------------------
# onflag function 
_ret_true() = true

export on_flag!
function on_flag!(f::Function, os::ObaServer, call_key::Tuple, flag_key, flag_keys...)
    flags = get!(os, [:FlagsRegs], call_key, Dict{String, Bool}())
    
    # use flag
    flag_key = string(flag_key, flag_keys...)
    flag = get(flags, flag_key, true) # missing key default true
    flags[flag_key] = false
    
    flag === true || return false

    return f()
end

on_flag!(os::ObaServer, call_key::Tuple, flag_key, flag_keys...) =
    on_flag!(_ret_true, os, call_key, flag_key, flag_keys...)

# --------------------------------------------------------------------
# This ignores args
function _FlagsRegs_flipflags_cbs(os, call_key, args...)
    regs = get!(os, [:FlagsRegs], call_key, Dict{String, Bool}())
    for flag_key in keys(regs)
        regs[flag_key] = true
    end
end