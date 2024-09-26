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

