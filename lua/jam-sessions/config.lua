local M = {
  options = {}
}

local defaults = {
  dir = vim.fn.expand(vim.fn.stdpath('data') .. '/sessions/'), -- directory where session files are saved
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', {}, defaults, opts or {})
  vim.fn.mkdir(M.options.dir, 'p')
end

return M
