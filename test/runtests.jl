using ObaServers
using ObaBase
using Test

@testset "ObaServers.jl" begin

    # globals
    let
        vault_dir = joinpath(pkgdir(ObaServers), "testvault")
        @assert isdir(vault_dir)
        run_init!(vault_dir) do
            # onsetup
            
            # config
            setstate!("Server.loop.trigger.hit.counter.max", 5)
            
            # callbacks
            register_callback!("Server.init.callbacks.onsetup") do
                # test configuration loading
                # see ObaServer.json
                @time getstate("test.config") === 123
            end
            
            register_callback!("Server.loop.callbacks.trigger.onhit") do
                @test true
                println("Server.loop.callbacks.trigger.onhit")
                counter = getstate("Server.loop.trigger.hit.counter")
                if counter == 2
                    foreach_note() do fn
                        touch(fn)
                        return :break 
                    end
                end
            end
            register_callback!("Server.loop.callbacks.trigger.onmiss") do
                # boostrap
                touch_trigger_file()
            end
            register_callback!("Vault.callbacks.notes.endpass") do
    
                new_reg = getstate(Vector{String}, "Vault.notes.new")
                mod_reg = getstate(Vector{String}, "Vault.notes.modified")
                up_reg = getstate(Vector{String}, "Vault.notes.updates")
                
                @show length(new_reg)
                @show length(mod_reg)
                @show length(up_reg)
    
                counter = getstate("Server.loop.trigger.hit.counter")
                if counter == 0
                    @test length(new_reg) == 2
                    @test length(mod_reg) == 0
                    @test length(up_reg) == 2
                end
                if counter == 1
                    @test length(new_reg) == 0
                    @test length(mod_reg) == 0
                    @test length(up_reg) == 0
                end
                if counter == 2
                    @test length(new_reg) == 0
                    @test length(mod_reg) == 1
                    @test length(up_reg) == 1
                end
                if counter == 3
                    @test length(new_reg) == 0
                    @test length(mod_reg) == 0
                    @test length(up_reg) == 0
                end
                
            end
        end
        run_loop!()
    end
    
end
