local M = {}

function M.get_buffer(buffer)
    return vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(buffer or 0), false)
end

function M.endswith(s, s2)
    return string.sub(s, -(#s2)) == s2
end


return M
