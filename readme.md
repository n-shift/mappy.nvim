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

### Setup

- `version` param creates an alias for `mappy:stable` or `mappy:nightly` function. By default mappy:map is a placeholder function. Accepts either `"nightly"` or `"stable"`

```lua
require("mappy")({
    version = "stable" | "nightly"
})
```

### Creating a "module"
Use `mappy:new()` to create a default module.
```lua
local module = require("mappy"):new()
```

### Setting values

#### Adding map table into module

```lua
module:set_maps({
    lhs = rhs,
    nested_ = {
        _lhs = rhs,
    }
})
```

#### Adding options table into module
```lua
module:set_opts({
    modes = "modechar" | { "mode", "char" },
    map = {...} -- Look at the docs of map function's api
})
```

####  Setting an event of module
```lua
module:set_event("VimEvent") -- see :h events
```

### Mapping

Note that `mappy:set_maps` function should be called before.

#### If `config.version` exists
```lua
module:map()
```

#### Stable mode

Stable mode is using vim.api.nvim_set_keymap function to set mappings. Useful for 6.1 and previous versions of neovim.

```lua
module:stable()
```

#### Nightly mode

Nightly mode is using vim.keymap.set function to set mappings. Neovim nightly is required. (probably will included in next stable release of neovim)

```lua
module:nightly()
```

#### VimEvent-based mapping

Requirements:
- `mappy:set_event` called
- `config.version` set

```lua
-- storage is a name for table with event map. must be different for every call.
module:event_map(storage)
```

### Which-key integration

####  Setting map
```lua
module:map({
    lhs = description,
    nested_ = {
        _lhs = description
    }
})
```

#### Setting description
```lua
mappy:link()
```
