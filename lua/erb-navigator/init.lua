local comment_jumplist = require('erb-navigator.comment_jumplist')
local views_jumplist = require('erb-navigator.views_jumplist')

local M = {}

M.settings = {
    comment_jumplist = comment_jumplist.settings,
    views_jumplist = views_jumplist.settings,
}

function M.setup(options)
    vim.tbl_deep_extend("force", M.settings, options)
end

return M
