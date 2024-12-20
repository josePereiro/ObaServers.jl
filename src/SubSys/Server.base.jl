## ..-.--- - .- .- .-- .-... .- .-.- .-... .- ....- 
# global state
const OBA = ObaServer()

## ..-.--- - .- .- .-- .-... .- .-.- .-... .- ....- 
# State dict interface

getstate() = OBA.state
getstate(key::String) = getindex(getstate(), key)
getstate(T::Type, key::String) = getindex(getstate(), key)::T
getstate(key::String, deft) = get(getstate(), key, deft)
getstate(T::Type, key::String, deft) = get(getstate(), key, deft)::T
getstate(f::Function, key::String) = get(f, getstate(), key)
getstate(f::Function, T::Type, key::String) = get(f, getstate(), key)::T

getstate!(key::String, deft) = get!(getstate(), key, deft)
getstate!(f::Function, key::String) = get!(f, getstate(), key)
getstate!(T::Type, key::String, deft) = getstate!(key, deft)::T
getstate!(f::Function, T::Type, key::String) = getstate!(f, key)::T

setstate!(key::String, val) = setindex!(getstate(), val, key)
setstate!(f::Function, key::Symbol) = setindex!(getstate(), f(), key)

# Allowes st += 1 kind of update
function upstate!(upfun::Function, key)
    st = getstate(key)
    st = upfun(st)
    setstate!(key, val)
    return st
end
function upstate!(upfun::Function, key, val0)
    st = getstate(key, val0)
    st = upfun(st)
    setstate!(key, val)
    return st
end

delstate!(key::String) = delete!(getstate(), key)

statekeys() = keys(getstate())
hasstate(key::String) = haskey(getstate(), key)

import Base.empty!
emptystate!() = empty!(getstate())

