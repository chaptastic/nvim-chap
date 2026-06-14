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
