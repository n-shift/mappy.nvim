-- Mappy.nvim --
-- ---------- --

local mappy = {}

---Walk over table of mappings, return vim api compatible ones
---@param map_table table
---@param prev string
---@return table
local function walk(map_table, prev)
	prev = prev or ""

	local outline = {}

	for lhs, group in pairs(map_table) do
        local rhs = group[1]
		if type(rhs) == "table" then
			outline = vim.tbl_deep_extend("error", outline, walk(rhs, prev .. lhs))
		else
			outline[prev .. lhs] = { rhs, group[2], group[3] }
            print(vim.inspect(outline))
		end
	end

	return outline
end

---Set mappings using nvim_set_keymap api
---@param maps table
---@param options table
mappy.stable = function (maps, options)
    for _, mappings in pairs(maps) do
        local outline = walk(mappings)
        for lhs, group in pairs(outline) do
            if type(group[2]) == "table" then
                for _, modechar in pairs(group[2]) do
                    vim.api.nvim_set_keymap(modechar, lhs, group[1], vim.tbl_deep_extend("force", options or {}, group[3] or {}))
                end
            else
                vim.api.nvim_set_keymap(group[2], lhs, group[1], vim.tbl_deep_extend("force", options or {}, group[3] or {}))
            end
        end
    end
end

---Set mappings using vim.keymap api
---@param maps table
---@param options table
mappy.nightly = function(maps, options)
    local outline = walk(maps)
    print(vim.inspect(outline))
    for lhs, group in pairs(outline) do
        if type(group[2]) == "table" then
            for _, modechar in pairs(group[2]) do
                vim.keymap.set(modechar, lhs, group[1], vim.tbl_deep_extend("force", options or {}, group[3] or {}))
            end
        else
            vim.keymap.set(group[2], lhs, group[1], vim.tbl_deep_extend("force", options or {}, group[3] or {})) 
        end
    end
end

return mappy
