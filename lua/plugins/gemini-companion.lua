return {
  "gutsavgupta/nvim-gemini-companion",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  event = "VeryLazy",
  config = function()
    -- You can configure the plugin by passing a table to the setup function
    -- Example:
    -- require("gemini").setup({
    --   cmds = {"gemini"},
    --   win = {
    --     preset = "floating",
    --     width = 0.8,
    --     height = 0.8,
    --   }
    -- })
    require("gemini").setup()
  end,
}
