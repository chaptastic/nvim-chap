require("mason").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "lua_ls",
    "stylua",
  },
})
require("mason-lspconfig").setup({
  automatic_enable = false,
})
vim.lsp.enable({
  "lua_ls",
})

-- Feed LSP completions into the native autocomplete popup (see `:h vim.lsp.completion`).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args) vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true }) end,
})
