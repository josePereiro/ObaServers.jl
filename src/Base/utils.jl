_concat(t::Tuple, ::Nothing) = t
_concat(::Nothing, t::Tuple) = t
_concat(t1::Tuple, t2::Tuple) = tuple(t1..., t2...)