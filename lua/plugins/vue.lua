return {

  require("lspconfig").volar.setup({
    filetypes = { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact" },
    init_options = {
      vue = { hybridMode = false },
      typescript = { tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib" },
    },
  }),
}
