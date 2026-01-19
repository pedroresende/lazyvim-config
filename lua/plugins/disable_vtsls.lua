return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.servers.vtsls = opts.servers.vtsls or { enabled = false }
    opts.servers.ts_ls = opts.servers.ts_ls or { enabled = false }
    opts.servers.tsserver = opts.servers.tsserver or { enabled = false }
    return opts
  end,
}
