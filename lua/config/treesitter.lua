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
    -- Only normal file buffers. Skips special UI buffers such as ui2's
    -- cmd/msg/pager/dialog windows (buftype "nofile"), prompts, help, etc.
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    -- `language.add` returns (true) when a parser is available and (nil, err)
    -- when not — it does NOT throw, so check its return value, not just that
    -- pcall succeeded.
    local ok, added = pcall(vim.treesitter.language.add, lang)
    if not (ok and added) then
      return
    end
    vim.treesitter.start(args.buf, lang)
    -- treesitter-based indentation (experimental on the main branch)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
