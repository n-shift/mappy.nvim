# mappy.nvim

It is a simple wrapper around `vim.keymap.set` function. Supports tables.

# Installation

```lua
use({"shift-d/mappy.nvim"})
```

# Usage
```lua
-- mappy({mappings}, {options})
-- For nightly builds of neovim use:
local mappy = require("mappy").nightly

-- For stable builds of neovim use:
local mappy = require("mappy").stable
mappy({
    mode = {
        ["lhs"] = "rhs",
        ["nested"] = {
            ["lhs"] = "rhs",
        },
    },
}, { options }) -- See :h vim.keymap
```
