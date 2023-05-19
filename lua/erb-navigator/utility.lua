local M = {}

function M.get_buffer()
    return vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
end

return M
