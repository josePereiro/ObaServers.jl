function TestUtils_init!(os::ObaServer; 
        dev_mode = false
    )

    # data
    set!(os, :TestUtils, Dict())
    set!(os, [:TestUtils], "dev_mode", dev_mode)
end

is_devmode(os::ObaServer) = get(os, [:TestUtils], "dev_mode")