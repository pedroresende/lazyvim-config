return {
  "EdenEast/nightfox.nvim",
  config = function()
    require("nightfox").setup({
      options = {
        transparent = true, -- Set to true if you want a transparent background
        styles = {
          comments = "italic",
          keywords = "bold",
          functions = "italic,bold",
          strings = "NONE",
          variables = "NONE",
        },
      },
    })
  end,
}
