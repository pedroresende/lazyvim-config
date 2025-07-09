-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.relativenumber = false
vim.opt.guifont = "JetBrainsMono Nerd Font:h14:Regular"
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { bold = false })
vim.api.nvim_set_hl(0, "LspInfoTitle", { bold = false })

vim.g.local_history_path = "/Users/pedroresende/.local_history"
vim.g.local_history_size = 1000
vim.g.local_history_enabled = 1
