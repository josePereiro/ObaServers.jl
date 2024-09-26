## ..-.--- - .- .- .-- .-... .- .-.- .-... .- ....- 
_getstate(oba::ObaServer) = oba.state

function Base.show(io::IO, oba::ObaServer)
    println(io, "ObaServer")
    
    root = get(_getstate(oba), "Vault.root.path", "")
    print(io, "root: ")
    printstyled(io, repr(root); color = :blue)
    println(io)
    
    println(io, "state: ")
    _keys = collect(keys(_getstate(oba)))
    sort!(_keys)
    for k in _keys
        v = _getstate(oba)[k]
        _valtype = false
        _valtype |= v isa Number 
        _valtype |= v isa String
        _valtype |= v isa Symbol
        _valtype |= v isa VersionNumber
        if _valtype
            printstyled(io, repr(k); color = :blue)
            printstyled(io, "::", typeof(v); color = :green)
            print(io, " = ")
            printstyled(io, repr(v); color = :blue)
            println(io)
        else
            printstyled(io, repr(k); color = :blue)
            printstyled(io, "::", typeof(v); color = :green)
            println(io)
        end
    end
    
    return nothing
end

