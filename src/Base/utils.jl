_concat(t::Tuple, ::Nothing) = t
_concat(::Nothing, t::Tuple) = t
_concat(t1::Tuple, t2::Tuple) = tuple(t1..., t2...)

ObaBase._obsidian_url(os::ObaServer, notefile) = _obsidian_url(vault_dir(os), notefile)