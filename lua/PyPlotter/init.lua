local M = {}

-- Default options
M.options = {
  run_code_on_buf_leave = true,
  paste_on_buf_leave = true,
  destroy_on_buf_leave = true,
}

function M.setup(opts)
  opts = opts or {}
  M.options = vim.tbl_extend('force', M.options, opts)
  require('PyPlotter.commands').setup(M.options)
end

return M
