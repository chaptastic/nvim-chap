require("mason").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "lua_ls",
    "stylua",
    "vtsls", -- TypeScript/JS language server
    "eslint-lsp", -- eslint language server (works with legacy .eslintrc)
    "prettierd", -- formatter daemon (reads project .prettierrc)
  },
})
require("mason-lspconfig").setup({
  automatic_enable = false,
})

-- Ruby: use the project's mise-managed ruby-lsp rather than a mason install, so
-- it runs under the project Ruby and the .ruby-lsp composed bundle (which pulls
-- in ruby-lsp-rails and the bundled rubocop + its config). `mise exec` resolves
-- the right Ruby from the LSP's root dir regardless of where nvim was launched.
vim.lsp.config("ruby_lsp", {
  cmd = { "mise", "exec", "--", "ruby-lsp" },
})

vim.lsp.enable({
  "lua_ls",
  "vtsls",
  "eslint",
  "ruby_lsp",
})

-- Feed LSP completions into the native autocomplete popup (see `:h vim.lsp.completion`).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args) vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true }) end,
})
