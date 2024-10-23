# NOTES v4

# Very simple loop
# 1. Listen trigger
#  - DONE: trigger must have the Obsidian active file
# 2. parse all vault
#  - DONE: Be lazy, reparse only modified notes
#  - DONE: record which files where modified
# 3. run all callbacks 
#  - A callback are functions that must be registered!
#  - There will be an interface for registring callbacks
#  - It could be a package in the same vault or a configurable path
# 4. goto 1

module ObaServers

    using ObaBase
    import ObaBase: _generate_rand_id
    using ObaASTs
    import EasyEvents
    import EasyEvents: AbstractEvent
    import EasyEvents: FileContentEvent, FileMTimeEvent, FileSizeEvent
    import EasyEvents: pull_event!, istraking, update!, event_type!
    import JSON
    import FilesTreeTools
    import FilesTreeTools: walkdown
    # using OrderedCollections
    # using Dates
    
    #! include Base
    include("Base/0_types.jl")
    include("Base/ObaServer.base.jl")
    include("Base/utils.jl")

    #! include SubSys
    include("SubSys/Callbacks.base.jl")
    include("SubSys/Callbacks.builtins.jl")
    include("SubSys/Parser.base.jl")
    include("SubSys/Server.base.jl")
    include("SubSys/Server.config.jl")
    include("SubSys/Server.init.jl")
    include("SubSys/Server.loop.jl")
    include("SubSys/Server.onepass.jl")
    include("SubSys/TriggerFiles.jl")
    include("SubSys/Vault.base.jl")

    ObaBase.@_exportall_non_underscore()
    
    #! include .
end