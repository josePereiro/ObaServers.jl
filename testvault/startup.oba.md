<!-- Run tests -->

```julia #!Oba -s
get!(__OS__, :Tests, Dict())
get!(__OS__, :TestsExtras, Dict())
```

```julia #!Oba
iter1 = get(__OS__, [:ServerLoop], "action_iter")
iter0 = get!(__OS__, [:TestsExtras], "iter0", iter1)
set!(__OS__, [:TestsExtras], "iter1", iter1)
```

```julia #!Oba
set!(__OS__, [:Tests], "ObaServers") do
    __OS__ isa ObaServer
end
```

```julia #!Oba
for (gl, test) in [
        ("__FILE__", __FILE__ == @__FILE__),
        ("__DIR__", __DIR__ == @__DIR__),
        ("__LINE__", __LINE__ == @__LINE__),
    ]
    set!(__OS__, [:Tests], string("macro", gl), test)
end
```

<!-- i flag -------------------------------------------------- -->
```julia #!Oba
set!(__OS__, [:Tests], "ignored", true)
```

```julia #!Oba -i
set!(__OS__, [:Tests], "ignored", false)
```

<!-- u flag -------------------------------------------------- -->
```julia #!Oba -u
iter_u = get(__OS__, [:ServerLoop], "action_iter")
set!(__OS__, [:TestsExtras], "iter_u", iter_u)
```

```julia #!Oba
iter1 = get(__OS__, [:TestsExtras], "iter1")
iter_u = get(__OS__, [:TestsExtras], "iter_u", -1)

# Nothing should be modifying this file for it to work
# This test both, that -u runs at least once and at the begining
_test = (iter_u != -1) && iter1 > iter_u
set!(__OS__, [:Tests], "modified", _test)
```

<!-- s flag -------------------------------------------------- -->
```julia #!Oba -s
iter_s = get(__OS__, [:ServerLoop], "action_iter")
set!(__OS__, [:TestsExtras], "iter_s", iter_s)
```

```julia #!Oba
iter_s = get(__OS__, [:TestsExtras], "iter_s", -1)
_test = (iter_s == 1)
set!(__OS__, [:Tests], "startup", _test)
```

<!-- ignore tags -------------------------------------------------- -->
```julia #!Oba -s
set!(__OS__, [:ObaScripts], "ignore_tags", ["Oba/Ignore"])
get!(__OS__, [:Tests], "ignored_tags", true)
get!(__OS__, [:Tests], "ignored_tags_cb", false)
```

```julia #!Oba -sg
function _ignoted_tags_test_cb(os, call_key, file, tag)
    _test = (basename(file) == "ignored_tags_tests.md")
    set!(os, [:Tests], "ignored_tags_cb", _test)
end
register_callback!(__OS__, (:ObaScripts, :on_ignored_file), :_ignoted_tags_test_cb)
```