return {
  "dawsers/file-history.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "snacks.nvim" },
  config = function()
    require("file_history").setup({
      backup_dir = vim.fn.stdpath("data") .. "/file_history_git",
      max_entries = 100, -- adjust as needed
    })

    local fh = require("file_history")
    vim.keymap.set("n", "<leader>Bh", fh.history, { desc = "File History" })
    vim.keymap.set("n", "<leader>Bf", fh.files, { desc = "All Tracked Files" })
    vim.keymap.set("n", "<leader>Bq", fh.query, { desc = "Query History" })
    vim.keymap.set("n", "<leader>Bb", fh.backup, { desc = "Manual Backup/Tag" })
  end,
}
