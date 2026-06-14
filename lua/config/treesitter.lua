-- nvim-treesitter `main` branch: install parsers, then start highlighting
-- (and treesitter indentation) per-buffer via FileType. See `:h treesitter`.

local parsers = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "ruby",
  "typescript",
  "tsx",
  "javascript",
  "json",
  "yaml",
  "toml",
  "html",
  "css",
  "markdown",
  "markdown_inline",
  "bash",
  "diff",
  "git_config",
  "gitcommit",
}

require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not (lang and pcall(vim.treesitter.language.add, lang)) then
      return
    end
    vim.treesitter.start(args.buf, lang)
    -- treesitter-based indentation (experimental on the main branch)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
