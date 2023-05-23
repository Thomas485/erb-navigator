local M = {}

function M.get_buffer(buffer)
    return vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(buffer or 0), false)
end

function M.endswith(s, s2)
    return string.sub(s, -(#s2)) == s2
end

function M.get_title(buffer)
    local app_root = vim.fs.find("app", { upward = true })
    if #app_root == 1 then
        local title = vim.api.nvim_buf_get_name(buffer)
        if vim.startswith(title, app_root[1]) then
            return string.sub(title, #app_root[1]+2)
        end
    end
    return "erb-navigator"
end


return M
