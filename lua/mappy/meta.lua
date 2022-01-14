--- @module meta
--- @author shift
--- @license GPLv3

--- Create meta object
--- @param rhs string
--- @return table meta
local function meta(rhs)
    local info = { custom = true, rhs = rhs }

    --- Set meta description
    --- @param description string
    function info:description(description)
        self.description = description
    end
    return info
end

return meta
