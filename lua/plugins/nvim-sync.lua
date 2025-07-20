return {
  "pedroresende/nvim-sync.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- Optional configuration
    auto_sync = false, -- Set to true for automatic sync on save
    sync_on_startup = true, -- Sync on Neovim startup
    branch = "test", -- Git branch to use
  },
}
