function _msg_file(os::ObaServer, msgid)
    msg_subdir = get(os, [:ObaScripts], "msgs_subdir")
    msg_dir = joinpath(vault_dir(os), msg_subdir)
    note_ext = get(os, [:VaultDir], "note_ext")
    return joinpath(msg_dir, string(msgid, ".oba", note_ext))
end

# -------------------------------------------------------------------
export send_msg

function _tee_to_msg(
        os::ObaServer, printfun::Function, formatter, msgid::AbstractString, args...; 
        kwargs...
    )
    msg_file = _msg_file(os, msgid)
    ObaBase._tee(printfun, [stdout, msg_file], args...; kwargs...)

    if !isnothing(formatter)
        txt = read(msg_file, String)
        txt = formatter(txt)
        write(msg_file, txt)
    end

    open_msgs = get(os, [:ObaScripts], "open_msgs", true)
    if open_msgs
        file_url = _obsidian_url(os, msg_file)
        try; run(`open $(file_url)`)
            catch err
                _info("At Catch", ""; file = string(@__FILE__, ":", @__LINE__))
                rethrow(err)
        end
    end

    return msg_file
end

function _msg_error(os::ObaServer, msg, err; 
        msgid = "ERROR",
        formatter = nothing, 
        kwargs...
    )
    _tee_to_msg(os, ObaBase._error, formatter, 
        msgid, msg, err, "!"; kwargs...
    )
end

function _msg_info(os::ObaServer, msg; 
        msgid = "INFO",
        formatter = nothing, 
        kwargs...
    )
    _tee_to_msg(os, ObaBase._info, formatter, 
        msgid, msg, ""; kwargs...
    )
end