return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Configure Deno LSP only for Deno projects
        denols = {
          root_dir = function(fname)
            local deno_root = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")(fname)
            local pkg_root = require("lspconfig.util").root_pattern("package.json")(fname)
            -- Only enable Deno LSP if no package.json exists
            return deno_root and not pkg_root
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
      },
    },
  },
}
