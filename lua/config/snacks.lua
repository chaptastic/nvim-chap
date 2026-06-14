local scratch = require("config.scratch")

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
  dashboard = {
    -- Default sections include a "startup" section that requires lazy.nvim's
    -- `lazy.stats`; we're on vim.pack, so define sections explicitly without it.
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = function() Snacks.picker.files() end },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = function() Snacks.picker.grep() end },
        { icon = " ", key = "r", desc = "Recent Files", action = function() Snacks.picker.recent() end },
        {
          icon = " ",
          key = "c",
          desc = "Config",
          action = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
        },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
    },
  },
  gh = {},
  gitbrowse = {},
  image = {},
  indent = {},
  lazygit = {},
  picker = {},
  scratch = scratch.opts,
  statuscolumn = {},
  words = {},
})

vim.g.snacks_animate = false

-- disable autocomplete in picker inputs
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_input",
  callback = function(event) vim.bo.autocomplete = false end,
})
