-- Mappy.nvim --
-- ---------- --

local mappy = {}

---Walk over table of mappings, return vim.keymap-compatible ones
---@param map_table table
---@param prev string
---@return table
local function walk(map_table, prev)
	prev = prev or ""

	local outline = {}

	for lhs, rhs in pairs(map_table) do
		if type(rhs) == "table" then
			outline = vim.tbl_deep_extend("error", outline, walk(rhs, prev .. lhs))
		else
			outline[prev .. lhs] = rhs
		end
	end

	return outline
end

---Generate reusable mapper function. Reused with different modes.
---@param api function
---@param lhs string
---@param rhs string | function
---@param opts table
---@return function
local function gen_mapper(api, lhs, rhs, opts)
    return function(mode)
        api(mode, lhs, rhs, opts)
    end
end


function mappy:set_maps(maps)
    self.maps = maps
    return self
end

function mappy:set_opts(opts)
    self.options = opts
    return self
end

function mappy:set_event(event)
    self.vim_event = event
    return self
end

function mappy:set_version(version)
    self.version = version
    return self
end

function mappy:set_storage(storage)
    self.storage = storage
    return self
end

---Set mappings using nvim_set_keymap api
function mappy:stable()
    local maps = self.maps
    local options = self.options or {}
    local outline = walk(maps)
    for lhs, rhs in pairs(outline) do
        if type(rhs) ~= "string" then
            if type(rhs) == "function" then
                vim.notify("You can map a lua function only if you are using nightly api!", "error", {title="mappy.nvim"})
            else
                vim.notify("You can only map a string in stable mode", "error", {title="mappy.nvim"})
            end
            return
        end
        local map = gen_mapper(vim.api.nvim_set_keymap, lhs, rhs, options.map)
        if type(options.mode) == "table" then
            for _, modechar in pairs(options.mode) do
                map(modechar)
            end
        elseif options.mode == nil then
            map("n")
        else
            map(options.mode)
        end
    end
    return self
end

---Set mappings using vim.keymap api
function mappy:nightly()
    local maps = self.maps
    local options = self.options or {}
    local outline = walk(maps)
    for lhs, rhs in pairs(outline) do
        if type(rhs) ~= "function" and type(rhs) ~= "string" then
            vim.notify("You can map only a string or a function as rhs!", "error", {title="mappy.nvim"})
        end
        local map = gen_mapper(vim.keymap.set, lhs, rhs, options.map)
        if options.mode == nil then
            map("n")
        else
            map(options.mode)
        end
    end
    return self
end

---Integration with which-key.nvim
function mappy:link()
    local maps = self.maps
    local present, wk = pcall(require, "which-key")
    if not present then
        vim.notify("folke/which-key.nvim could not be loaded, aborting linking", "error", {title = "mappy.nvim"})
        return
    end
    local links = walk(maps)
    for mapping, description in pairs(links) do
        wk.register({ [mapping] = { name = description } })
    end
    return self
end

-- TODO: clean autocmds on the mappy setup

---Automap only if event if triggered
function mappy:event_map()
    local maps = self.maps
    local event = self.vim_event
    local version = self.version
    local opts = self.options
    local storage = self.storage
    if storage == nil then
        vim.notify("Specify global variable name where mappings will be stored","error", {title="mappy.nvim"})
        return
    end
    opts = opts or {}
    vim.g[storage] = { maps = maps, opts = opts }
    vim.cmd("augroup mappy")
    vim.cmd("au "..event.." lua require('mappy')."..version.."(vim.g."..storage..".maps, vim.g.)"..storage..".opts")
    vim.cmd("augroup END")
    return self
end

function mappy:new()
    self.maps = nil
    self.options = nil
    self.vim_event = nil
    self.version = nil
    self.storage = nil

    return self
end

return mappy
