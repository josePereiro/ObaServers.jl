function _recursive_getindex(dict::Dict, keys::Vector) 
    for key in keys
        dict = dict[key]::Dict
    end
    return dict
end

_do_nothing(_...) = nothing

_read_json(path) = JSON.parse(read(path, String))

function _write_json(path::String, obj; indent = 1)
    open(path, "w") do io
        write(io, JSON.json(obj, indent))
    end
end

_func_vec() = Function[]

function locate_stateid(pt)
    srcdir = joinpath(pkgdir(ObaServers), "src")
    for (root, dirs, files) in walkdir(srcdir)
        for file in files
            endswith(file, ".jl") || continue
            path = joinpath(root, file)
            # println(path) # path to files
            for (li, line) in enumerate(eachline(path))
                contains(line, pt) || continue
                printstyled(line; color = :green)
                println()
                printstyled(path, ":", li; color = :blue)  
                println()
            end
        end
    end
end
