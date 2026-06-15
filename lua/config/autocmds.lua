-- Terminal buffers read better without line numbers, and should drop you
-- straight into insert mode so you can start typing immediately.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd.startinsert()
  end,
})
