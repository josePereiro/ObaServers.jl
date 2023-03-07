using ObaServers
using ObaBase
using Test

@testset "ObaServers.jl" begin

    # obascript tests
    let 
        vault_dir = joinpath(tempdir(), "vault")
        try
            _info("ObaScripts Tests", "="; vault_dir); println()
            
            rm(vault_dir; recursive = true, force = true)
    
            test_os = create_testvault(vault_dir; dev_mode = false)
            
            run_server_loop(test_os; 
                niters = 3,
                force_trigger = true,
            )
    
            # The testvault inject tests results into the ObaServers
            _info("Tests Done", "="); println()
            for (name, res) in get(test_os, :Tests)
                println(name, " => ", res)
                @test res
            end
    
        finally
            rm(vault_dir; recursive = true, force = true)
        end
        return nothing
    end
end
