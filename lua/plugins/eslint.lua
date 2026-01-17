return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = {
        settings = {
          experimental = {
            useFlatConfig = true,
          },
          workingDirectories = { mode = "auto" },
        },
      },
    },
  },
}
