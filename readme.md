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
- Register mappings based on condition (filetype, event, buffername)
- [which-key.nvim](https://github.com/folke/which-key.nvim) integration

## Features

- Stable-compatible
- Nested mappings
- Multiple modes

## Usage
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
