require("snacks").setup({
  bigfile = {
    notify = true,
    size = 1.5 * 1024 * 1024,
    line_length = 1000,
    setup = function(ctx)
      if vim.fn.exists(":NoMatchParen") ~= 0 then
        vim.cmd([[NoMatchParen]])
      end
      Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
      vim.b.completion = false
      vim.b.minianimate_disable = true
      vim.b.minihipatterns_disable = true
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ctx.buf) then
          vim.bo[ctx.buf].syntax = ctx.ft
        end
      end)
    end,
  },
  dashboard = {},
  gh = {},
  gitbrowse = {},
  image = {},
  indent = {},
  lazygit = {},
  picker = {},
  statuscolumn = {},
  words = {},
})

vim.g.snacks_animate = false

-- disable autocomplete in picker inputs
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_input",
  callback = function(event) vim.bo.autocomplete = false end,
})
