return {
  require("lspconfig").vtsls.setup({
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    settings = {
      typescript = {
        tsserver = { useSeparateSyntaxServer = true },
        suggest = { completeFunctionCalls = true },
        preferences = { importModuleSpecifier = "non-relative" },
      },
      vtsls = { enableMoveToFileCodeAction = true },
    },
  }),
}
