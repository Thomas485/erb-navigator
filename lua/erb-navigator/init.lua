local settings = require('erb-navigator.settings')
local comment_jumplist = require('erb-navigator.comment_jumplist')
local views_jumplist = require('erb-navigator.views_jumplist')

local M = {}

function M.setup(options)
    settings.settings = vim.tbl_deep_extend("force", settings.settings, options)
end

return M
