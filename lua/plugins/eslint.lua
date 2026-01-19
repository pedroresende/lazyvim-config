return {
  -- Diagnostic configuration for ESLint
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure diagnostics are configured properly
      opts.diagnostics = opts.diagnostics or {}
      opts.diagnostics.virtual_text = opts.diagnostics.virtual_text or {}
      opts.diagnostics.virtual_text.spacing = 4
      opts.diagnostics.virtual_text.prefix = "●"
      opts.diagnostics.signs = opts.diagnostics.signs or {}
      opts.diagnostics.signs.text = opts.diagnostics.signs.text or {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
      }
      opts.diagnostics.underline = true
      opts.diagnostics.update_in_insert = false
      opts.diagnostics.severity_sort = true

      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            experimental = {
              useFlatConfig = true,
            },
            workingDirectories = { mode = "auto" },
            validate = "on",
            run = "onType",
            format = { enable = true },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("package.json", "eslint.config.js")(fname)
          end,
          on_attach = function(client, bufnr)
            print("ESLint LSP attached to: " .. vim.api.nvim_buf_get_name(bufnr))
            vim.diagnostic.enable(bufnr)

            -- Ensure diagnostic display is enabled for this buffer
            vim.wo.signcolumn = "yes"

            -- Force diagnostic config for this client
            vim.diagnostic.config({
              virtual_text = {
                spacing = 4,
                prefix = "●",
                severity = { min = vim.diagnostic.severity.HINT },
              },
              signs = {
                text = {
                  [vim.diagnostic.severity.ERROR] = "",
                  [vim.diagnostic.severity.WARN] = "",
                  [vim.diagnostic.severity.HINT] = "",
                  [vim.diagnostic.severity.INFO] = "",
                },
              },
              underline = true,
              severity_sort = true,
            }, nil)

            -- Request diagnostics immediately
            vim.defer_fn(function()
              -- Use the standard LSP diagnostic request
              vim.lsp.buf_request(bufnr, 'textDocument/diagnostic', {
                textDocument = { uri = vim.uri_from_bufnr(bufnr) }
              })

              -- Also force show diagnostics after a short delay
              vim.defer_fn(function()
                vim.diagnostic.show(nil, bufnr)
                vim.cmd("redraw!")
              end, 1000)
            end, 500)
          end,
          on_init = function(client)
            print("ESLint LSP initialized: " .. client.name)
          end,
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
          },
        },
      },
    },
  },
  -- Auto-start ESLint for TypeScript files
  {
    "nvim-lspconfig",
    event = "BufReadPre *.ts,*.tsx,*.js,*.jsx",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function()
          vim.defer_fn(function()
            if vim.fn.filereadable("eslint.config.js") == 1 or vim.fn.filereadable("package.json") == 1 then
              local clients = vim.lsp.get_active_clients({ name = "eslint" })
              if #clients == 0 then
                vim.cmd("LspStart eslint")
              end
            end
          end, 100)
        end,
      })

      -- Ensure diagnostics work for TypeScript files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function()
          -- Force enable diagnostics for this buffer
          local bufnr = vim.api.nvim_get_current_buf()
          vim.diagnostic.enable(bufnr)
          vim.wo.signcolumn = "yes"

          -- Force diagnostic config
          vim.diagnostic.config({
            virtual_text = {
              spacing = 4,
              prefix = "●",
              severity = { min = vim.diagnostic.severity.HINT },
            },
            signs = {
              text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.HINT] = "",
                [vim.diagnostic.severity.INFO] = "",
              },
            },
            underline = true,
            severity_sort = true,
          }, nil)
        end,
      })

      -- Force diagnostic refresh on save
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.defer_fn(function()
            vim.diagnostic.show(nil, bufnr)
            vim.cmd("redraw!")
          end, 100)
        end,
      })

      -- Add keymaps for testing
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function()
          vim.keymap.set("n", "<leader>ld", ":DebugLSP<CR>", { buffer = true, desc = "Debug LSP" })
          vim.keymap.set("n", "<leader>lf", ":ForceESLint<CR>", { buffer = true, desc = "Force ESLint" })
          vim.keymap.set("n", "<leader>lt", ":TestESLint<CR>", { buffer = true, desc = "Test ESLint CLI" })
          vim.keymap.set("n", "<leader>ls", ":ShowDiags<CR>", { buffer = true, desc = "Show Diagnostics" })
          vim.keymap.set("n", "<leader>le", ":ForceDiagDisplay<CR>", { buffer = true, desc = "Force Diagnostic Display" })
          vim.keymap.set("n", "<leader>lc", ":CheckAll<CR>", { buffer = true, desc = "Comprehensive Check" })
          vim.keymap.set("n", "<leader>lz", ":SimpleTest<CR>", { buffer = true, desc = "Simple Diagnostic Test" })
          vim.keymap.set("n", "<leader>la", ":ForceAddESLint<CR>", { buffer = true, desc = "Force Add ESLint Diagnostics" })
        end,
      })
    end,
  },
}