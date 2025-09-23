return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Configure Deno LSP
        denols = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")(fname)
          end,
          init_options = {
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  ["https://deno.land"] = true,
                  ["https://cdn.nest.land"] = true,
                  ["https://crux.land"] = true,
                },
              },
            },
          },
        },
        -- Disable tsserver when deno.json is present
        tsserver = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("package.json")(fname)
          end,
        },
      },
    },
  },
}
