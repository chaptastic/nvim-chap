-- Set leaders before anything else loads, so plugin mappings created during
-- setup() capture the right leader (see `:h mapleader`).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("vim._core.ui2").enable()

require("config")
