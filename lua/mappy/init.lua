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
        local map = gen_mapper(vim.keymap.set, lhs, rhs, options.map)
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

return mappy
