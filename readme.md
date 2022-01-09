# mappy.nvim

It is a simple wrapper around `vim.keymap.set` function. Supports tables.

# Installation

```lua
use({"shift-d/mappy.nvim"})
```

# Usage
If you are using nightly builds of neovim use:
```lua
-- mappy({mappings}, {options})
local mappy = require("mappy").nightly
mappy({
    mode = {
        ["lhs"] = "rhs",
        ["nested"] = {
            ["thing"] = lua_function,
        },
    },
}, { options }) -- See :h vim.keymap
```

If you are using stable builds of neovim use:
```lua
-- mappy({mappings}, {options})
local mappy = require("mappy").stable
mappy({
    mode = {
        ["lhs"] = "rhs",
        ["nested"] = {
            ["thing"] = lua_function,
        },
    },
}, { options }) -- See :h vim.keymap
```
