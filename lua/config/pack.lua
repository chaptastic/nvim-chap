local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({
  gh("folke/tokyonight.nvim"),
  -- Original nvim-treesitter was archived (Apr 2026); this is the maintained
  -- community fork. Parser sources come from the separate registry dependency.
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
  gh("stevearc/oil.nvim"),
})

vim.cmd([[colorscheme tokyonight-night]])

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

require("oil").setup({
  default_file_explorer = true,
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
})

require("nvim-surround").setup()
require("nvim-surround-wk").setup()
