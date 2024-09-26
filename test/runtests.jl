using ObaServers
using ObaBase
using Test

@testset "ObaServers.jl" begin

    # globals
    vault_dir = joinpath(tempdir(), "test.vault")
    
    # test trigger file pull/touch
    try
        oba = ObaServer(vault_dir)
        flag = pull_trigger_file!(oba)
        @test !flag 
        touch_trigger_file(oba)
        flag = pull_trigger_file!(oba)
        @test flag 
    catch err
        rm(vault_dir; recursive = true, force = true)
    end
end
