--- @module mappy
--- @author shift
--- @license GPLv3

local mappy = {}

--- Create empty metatable
function mappy:new()
    self.maps = nil
    self.options = nil
    self.vim_event = nil
    self.storage = nil

    return self
end

--- Placeholder function
function mappy:map()
    vim.notify("Set config.version in mappy:setup to use this function!", "info", { title = "mappy.nvim" })
end

--- Setup mappy.nvim config
--- @param config table mappy.nvim config
function mappy:setup(config)
    -- Clean mappy autocmds
    vim.cmd("augroup mappy")
    vim.cmd("au!")
    vim.cmd("augroup END")

    -- Set up mapper
    if config.version == "stable" then
        self.map = self.stable
    elseif config.version == "nightly" then
        self.map = self.nightly
    end
end

--- Walk over table of mappings, return vim.keymap-compatible ones
--- @param map_table table table of mappings
--- @param prev string previous lhs
--- @return table table output lhs = rhs mappings
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

--- Generate reusable mapper function. Reused with different modes.
--- @param api function function that will be used for mapping
--- @param lhs string
--- @param rhs string | function
--- @param opts table mapper options
--- @return function generated mapper function
local function gen_mapper(api, lhs, rhs, opts)
    return function(mode)
        api(mode, lhs, rhs, opts)
    end
end


--- Set module maps
--- @param maps table nested keymap table
--- @return table
function mappy:set_maps(maps)
    self.maps = maps
    return self
end

--- Set module options
--- @param opts table {mode, map}
--- @return table
function mappy:set_opts(opts)
    self.options = opts
    return self
end

--- Set module VimEvent
--- @param event string see :h event
--- @return table
function mappy:set_event(event)
    self.vim_event = event
    return self
end

--- Set mappings using nvim_set_keymap api
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

--- Set mappings using vim.keymap api
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

--- Integration with which-key.nvim
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

--- Automap only if event if triggered
--- @param storage string name of variable that contains event map
function mappy:event_map(storage)
    local maps = self.maps
    local event = self.vim_event
    local opts = self.options
    if storage == nil then
        vim.notify("Specify global variable name where mappings will be stored","error", {title="mappy.nvim"})
        return
    end
    opts = opts or {}
    self.storage = { maps = maps, opts = opts }
    vim.cmd("augroup mappy")
    vim.cmd("au "..event.." lua require('mappy'):new():set_maps(require('mappy')."..storage..".maps):set_opts("..storage..".opts):nightly()")
    vim.cmd("augroup END")
    return self
end

return mappy
