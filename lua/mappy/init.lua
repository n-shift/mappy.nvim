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

---Set mappings using nvim_set_keymap api
---@param maps table
---@param options table
mappy.stable = function (maps, options)
    options = options or {}
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
end

---Set mappings using vim.keymap api
---@param maps table
---@param options table
mappy.nightly = function(maps, options)
    options = options or {}
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
end

---Integration with which-key.nvim
---@param maps table
mappy.link = function(maps)
    local present, wk = pcall(require, "which-key")
    if not present then
        vim.notify("folke/which-key.nvim could not be loaded, aborting linking", "error", {title = "mappy.nvim"})
        return
    end
    local links = walk(maps)
    for mapping, description in pairs(links) do
        wk.register({ [mapping] = { name = description } })
    end
end

-- TODO: clean autocmds on the mappy setup

---Automap only if event if triggered
---@param maps table
---@param event string
---@param version string
---@param opts table
---@param storage string
mappy.event = function(maps, event, version, opts, storage)
    if storage == nil then
        vim.notify("Specify global variable name where mappings will be stored","error", {title="mappy.nvim"})
        return
    end
    opts = opts or {}
    vim.g[storage] = { maps = maps, opts = opts }
    vim.cmd("augroup mappy")
    vim.cmd("au "..event.." lua require('mappy')."..version.."(vim.g."..storage..".maps, vim.g.)"..storage..".opts")
    vim.cmd("augroup END")
end

return mappy
