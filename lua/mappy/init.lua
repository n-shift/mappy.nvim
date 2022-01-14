--- @module mappy
--- @author shift
--- @license GPLv3

local mappy = {}
local utils = require("mappy.utils")

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
    vim.notify("Set config.version in mappy:setup to use this function!", "warn", { title = "mappy.nvim" })
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
    local outline = utils.walk(maps)
    for lhs, rhs in pairs(outline) do
        if type(rhs) ~= "string" and rhs.rhs == nil then
            if type(rhs) == "function" then
                utils.notify_error("You can map a lua function only if you are using nightly api!")
            else
                utils.notify_error("You can only map a string in stable mode")
            end
            return
        end
        local map = utils.gen_mapper(vim.api.nvim_set_keymap, lhs, rhs, options.map)
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
    local outline = utils.walk(maps)
    for lhs, rhs in pairs(outline) do
        if type(rhs) ~= "function" and type(rhs) ~= "string" and not rhs.custom then
            utils.notify_error("You can map only a string or a function as rhs!")
            return
        end
        local map = utils.gen_mapper(vim.keymap.set, lhs, rhs, options.map)
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
        utils.notify_error("folke/which-key.nvim could not be loaded, aborting linking")
        return
    end
    local links = utils.walk(maps)
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
        utils.notify_error("Specify global variable name where mappings will be stored")
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
