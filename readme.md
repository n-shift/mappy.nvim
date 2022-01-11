<div align="center">

# mappy.nvim

mappy.nvim is a simple wrapper around `vim.keymap.set` for nightly builds or `vim.api.nvim_set_keymap` for stable builds function. Supports tables.

![Status](https://img.shields.io/badge/status-WIP-informational?style=flat-square&logo=github)
[![License](https://img.shields.io/github/license/shift-d/mappy.nvim?style=flat-square)](https://github.com/shift-d/mappy.nvim/blob/main/license)
[![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white&style=flat-square)](https://github.com/neovim/neovim)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)
</div>

## Installation

```lua
use({"shift-d/mappy.nvim"})
```

## Planned features

- Telescope picker to view your mappings

## Features

- Stable-compatible
- Nested mappings
- Multiple modes
- [which-key.nvim](https://github.com/folke/which-key.nvim) integration
- Register mappings based on event

## Usage

### Mapping
```lua
-- mappy({mappings}, {options})
-- For nightly builds of neovim use:
local mappy = require("mappy").nightly
-- For stable builds of neovim use:
local mappy = require("mappy").stable

mappy({
    lhs = rhs,
    lhs = {
        lhs = rhs,
    },
}, {
    -- "n" by default
    mode = { "n", "i" },
    -- or
    mode = "i",
    map = {
        -- api function's options (:h vim.keymap or :h nvim_set_keymap)
    },
})
```

### Integration with which-key
```lua
local mappy = require("mappy").link
mappy({
    lhs = description,
    lhs = {
        lhs = description,
    },
})
```

### Register on VimEvent
```lua
local mappy = require("mappy").event
-- maps - table with mappings (look at previous examples)
-- event - vim event, just like in autocmds (:h event)
-- version - "stable" or "nightly"
-- options - see previous examples
-- storage - global variable with mappings stored name (must be different for every .event call)
mappy(maps, event, version, options, storage)
```
