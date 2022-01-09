# mappy.nvim

mappy.nvim is a simple wrapper around `vim.keymap.set` for nightly builds or `vim.api.nvim_set_keymap` for stable builds function. Supports tables.

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
