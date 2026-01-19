local function check_lsp()
  print("=== LSP Status Check ===")
  
  -- Check active clients
  local clients = vim.lsp.get_active_clients()
  print("Active LSP clients:")
  for _, client in ipairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
  end
  
  -- Check current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  print("Current buffer: " .. bufname)
  
  -- Check diagnostics
  local diagnostics = vim.diagnostic.get(bufnr)
  print("Diagnostics count: " .. #diagnostics)
  
  -- Check if ESLint is configured
  local has_eslint_config = vim.fn.filereadable("eslint.config.js") == 1
  print("Has eslint.config.js: " .. tostring(has_eslint_config))
  
  -- Check package.json
  local has_package_json = vim.fn.filereadable("package.json") == 1
  print("Has package.json: " .. tostring(has_package_json))
end

vim.api.nvim_create_user_command('CheckLSP', check_lsp, {})