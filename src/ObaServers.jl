module ObaServers

    using ObaBase
    import ObaBase: _generate_rand_id
    using ObaASTs
    import EasyEvents
    import EasyEvents: FileContentEvent, FileMTimeEvent, FileSizeEvent
    import EasyEvents: has_event!
    import FilesTreeTools
    import FilesTreeTools: walkdown
    using OrderedCollections
    using Dates

    # TODO: Make a better error handling

    #! include Types
    include("Types/ObaServer.jl")

    #! include Base
    include("Base/utils.jl")
    
    #! include TriggerFile
    include("TriggerFile/trigger.jl")
    
    #! include FileTracker
    include("FileTracker/filetracker.jl")
    
    #! include CallbacksReg
    include("CallbacksReg/callbacks.jl")
    
    #! include NotesASTs
    include("NotesASTs/noteasts.jl")
    include("NotesASTs/noteasts_cbs.jl")
    
    #! include ServerLoop
    include("ServerLoop/loop.jl")
    include("ServerLoop/loop_cbs.jl")

    #! include VaultDir
    include("VaultDir/vault.jl")
    include("VaultDir/vault_cds.jl")

    #! include ObaScripts
    include("ObaScripts/globals.jl")
    include("ObaScripts/msgfiles.jl")
    include("ObaScripts/obascripts.jl")
    include("ObaScripts/obascripts_cbs.jl")
    include("ObaScripts/runscripts.jl")
    
    #! include TestUtils
    include("TestUtils/testutils.jl")
    include("TestUtils/testvault.jl")
    
    #! include FlagsRegs
    include("FlagsRegs/flagsregs.jl")

    #! include .

end