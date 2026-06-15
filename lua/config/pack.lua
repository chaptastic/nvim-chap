local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({
  gh("rose-pine/neovim"),
  gh("neovim-treesitter/treesitter-parser-registry"),
  gh("neovim-treesitter/nvim-treesitter"),
  gh("mason-org/mason.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  gh("folke/which-key.nvim"),
  gh("nvim-mini/mini.icons"),
  gh("folke/snacks.nvim"),
  gh("kylechui/nvim-surround"),
  gh("gregorias/nvim-surround-wk"),
  gh("stevearc/conform.nvim"),
  gh("coder/claudecode.nvim"),
})

vim.cmd([[colorscheme rose-pine-main]])

require("which-key").setup()

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    css = { "prettierd" },
    scss = { "prettierd" },
  },
  -- Auto-format on save everywhere except Ruby/ERB: ruby-lsp formats the whole
  -- file through rubocop, which makes noisy diffs on legacy files. Format those
  -- on demand with <leader>cf instead.
  format_after_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "ruby" or ft == "eruby" then
      return nil
    end
    return { lsp_format = "fallback" }
  end,
})

require("nvim-surround").setup()
require("nvim-surround-wk").setup()

require("claudecode").setup({
  terminal = {
    provider = "snacks",
    snacks_win_opts = {
      position = "bottom",
      width = 1.0,
      height = 0.4,
      border = "single",
      keys = {
        claude_hide = { "<C-,>", function(self) self:hide() end, mode = "t", desc = "Hide (Ctrl+,)" },
      },
    },
  },
})
