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

---Set mappings using nvim_set_keymap api
---@param maps table
---@param options table
mappy.stable = function (maps, options)
    for mode, mode_maps in pairs(maps) do
        local outline = walk(mode_maps)
        for lhs, rhs in pairs(outline) do
            vim.api.nvim_set_keymap(mode, lhs, rhs, options)
        end
    end
end

---Set mappings using vim.keymap api
---@param maps table
---@param options table
mappy.nightly = function(maps, options)
	for mode, mode_maps in pairs(maps) do
		local outline = walk(mode_maps)
		for lhs, rhs in pairs(outline) do
			vim.keymap.set(mode, lhs, rhs, options)
		end
	end
end

return mappy
