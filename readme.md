# mappy.nvim

It is a simple wrapper around `vim.keymap.set` function. Supports tables.

# Installation

```lua
use({"shift-d/mappy.nvim"})
```

# Usage

```lua
-- mappy({mappings}, {options})
local mappy = require("mappy")
mappy({
    mode = {
        ["lhs"] = "rhs",
        ["nested"] = {
            ["thing"] = lua_function,
        },
    },
}, { options }) -- See :h vim.keymap
```
