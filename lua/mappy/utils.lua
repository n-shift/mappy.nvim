--- @module utils
--- @author shift
--- @license GPLv3

local utils = {}

--- Walk over table of mappings, return vim.keymap-compatible ones
--- @param map_table table table of mappings
--- @param prev string previous lhs
--- @return table table output lhs = rhs mappings
function utils.walk(map_table, prev)
	prev = prev or ""

	local outline = {}

	for lhs, rhs in pairs(map_table) do
		if type(rhs) == "table" then
			outline = vim.tbl_deep_extend("error", outline, utils.walk(rhs, prev .. lhs))
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
function utils.gen_mapper(api, lhs, rhs, opts)
    return function(mode)
        api(mode, lhs, rhs, opts)
    end
end

--- Alias for error log
--- @param message string error message
function utils.notify_error(message)
    vim.notify(message, "error", { title = "mappy.nvim" })
end

return utils
