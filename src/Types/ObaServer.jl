export ObaServer
struct ObaServer
    state::Dict{Symbol, Dict{Any, Any}}
    ObaServer() = new(Dict{Symbol, Dict{Any, Any}}())
end

function Base.show(io::IO, os::ObaServer)
    println(io, "ObaServer")
    try; println(io, "    vault: ", vault_dir(os)) catch err; end
    println(io, "    subsystems: ", collect(keys(os.state)))
    return nothing
end

function _subkeys(os::ObaServer, keys::Vector) 
    dict = os.state::Dict
    for key in keys
        dict = dict[key]::Dict
    end
    return dict
end

Base.get(os::ObaServer, valkey::Symbol) = getindex(os.state, valkey)
Base.get(os::ObaServer, valkey::Symbol, deft) = get(os.state, valkey, deft)
Base.get(os::ObaServer, subkeys::Vector, valkey, deft) = get(_subkeys(os, subkeys), valkey, deft)
Base.get(os::ObaServer, subkeys::Vector, valkey) = _subkeys(os, subkeys)[valkey]

Base.get!(os::ObaServer, valkey::Symbol, deft) = get!(os.state, valkey, deft)
Base.get!(os::ObaServer, subkeys::Vector, valkey, deft) = get!(_subkeys(os, subkeys), valkey, deft)

Base.get(f::Function, os::ObaServer, valkey) = get(f, os.state, valkey)
Base.get(f::Function, os::ObaServer, subkeys::Vector, valkey) = get(f, _subkeys(os, subkeys), valkey)

Base.get!(f::Function, os::ObaServer, valkey) = get!(f, os.state, valkey)
Base.get!(f::Function, os::ObaServer, subkeys::Vector, valkey) = get!(f, _subkeys(os, subkeys), valkey)

export set!
set!(os::ObaServer, valkey::Symbol, val) = setindex!(os.state, val, valkey)
set!(f::Function, os::ObaServer, valkey::Symbol) = setindex!(os.state, f(), valkey)
set!(os::ObaServer, subkeys::Vector, valkey, val) = setindex!(_subkeys(os, subkeys), val, valkey)
set!(f::Function, os::ObaServer, subkeys::Vector, valkey) = setindex!(_subkeys(os, subkeys), f(), valkey)

Base.keys(os::ObaServer) = keys(os.state)

Base.delete!(os::ObaServer, valkey::Symbol) = delete!(os.state, valkey)
Base.delete!(os::ObaServer, subkeys::Vector, valkey) = delete!(_subkeys(os, subkeys), valkey)

Base.haskey(os::ObaServer, valkey::Symbol) = haskey(os.state, valkey)
Base.haskey(os::ObaServer, subkeys::Vector, valkey) = haskey(_subkeys(os, subkeys), valkey)

Base.empty!(os::ObaServer) = (empty!(os.state); os)

# DefaultInit
function ObaServer(vault_dir::AbstractString;
        vault_note_ext = ".md",
        dev_mode = false
    )

    os = ObaServer();

    # inits
    ServerLoop_init!(os)
    VaultDir_init!(os; 
        dir = vault_dir, 
        note_ext = vault_note_ext
    )
    FileTracker_init!(os)
    TriggerFile_init!(os)
    NotesASTs_init!(os)
    ObaScripts_init!(os)
    TestUtils_init!(os; dev_mode)
    FlagsRegs_init!(os)

    return os

end