local M = {}

local function is_range4(value)
    return type(value) == "table"
        and type(value[1]) == "number"
        and type(value[2]) == "number"
        and type(value[3]) == "number"
        and type(value[4]) == "number"
end

local function unwrap_node(value)
    if type(value) ~= "table" or is_range4(value) then
        return value
    end

    if value.node ~= nil then
        return unwrap_node(value.node)
    end

    if value[1] ~= nil then
        return unwrap_node(value[1])
    end

    return value
end

function M.apply()
    if vim.fn.has("nvim-0.12") == 0 then
        return
    end

    local ts = vim.treesitter

    if ts._codex_compat_patched then
        return
    end

    local original_get_range = ts.get_range
    local original_get_node_range = ts.get_node_range
    local original_get_node_text = ts.get_node_text

    ts.get_range = function(node, source, metadata)
        return original_get_range(unwrap_node(node), source, metadata)
    end

    ts.get_node_range = function(node_or_range)
        if is_range4(node_or_range) then
            return original_get_node_range(node_or_range)
        end

        return original_get_node_range(unwrap_node(node_or_range))
    end

    ts.get_node_text = function(node, source, opts)
        return original_get_node_text(unwrap_node(node), source, opts)
    end

    ts._codex_compat_patched = true
end

return M
