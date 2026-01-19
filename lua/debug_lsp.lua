-- Debug script to check LSP status
local function debug_lsp()
  print("=== LSP Debug Info ===")

  -- Check active clients
  local clients = vim.lsp.get_active_clients()
  print("\nActive LSP clients:")
  for _, client in ipairs(clients) do
    print(string.format("  - %s (id: %d) - %s", client.name, client.id, client.config.root_dir or "no root"))
  end

  -- Check current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo.filetype
  print(string.format("\nCurrent buffer: %s (%s)", bufname, filetype))

  -- Check diagnostics
  local diagnostics = vim.diagnostic.get(bufnr)
  print(string.format("Diagnostics count: %d", #diagnostics))
  if #diagnostics > 0 then
    print("First few diagnostics:")
    for i = 1, math.min(3, #diagnostics) do
      local diag = diagnostics[i]
      print(string.format("  - %s: %s (line %d)", diag.severity == 1 and "Error" or "Warning", diag.message, diag.lnum + 1))
    end
  end

  -- Check if ESLint config exists
  local eslint_config_exists = vim.fn.filereadable("eslint.config.js") == 1
  local package_json_exists = vim.fn.filereadable("package.json") == 1
  print(string.format("\nConfig files: eslint.config.js=%s, package.json=%s", eslint_config_exists and "yes" or "no", package_json_exists and "yes" or "no"))

  -- Try to start ESLint manually
  print("\nAttempting to start ESLint LSP...")
  local success, err = pcall(function()
    vim.cmd("LspStart eslint")
  end)
  if success then
    print("LspStart eslint: success")
  else
    print("LspStart eslint: failed - " .. tostring(err))
  end
end

-- Function to force ESLint check
local function force_eslint_check()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "eslint" })

  if #clients > 0 then
    print("ESLint client found, requesting diagnostics...")
    -- Force a document save to trigger ESLint
    vim.cmd("write")
    vim.defer_fn(function()
      vim.lsp.buf_request(bufnr, 'textDocument/diagnostic', {
        textDocument = vim.lsp.util.make_text_document_params(bufnr)
      })
    end, 500)
  else
    print("No ESLint client found for current buffer")
    -- Try to start it
    vim.cmd("LspStart eslint")
    vim.defer_fn(function()
      local new_clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "eslint" })
      if #new_clients > 0 then
        print("ESLint started, triggering diagnostics...")
        vim.cmd("write") -- Save to trigger ESLint
      else
        print("Failed to start ESLint. Using manual ESLint CLI instead.")
      end
    end, 1000)
  end
end

-- Function to test ESLint manually
local function test_eslint_cli()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then
    print("No file name")
    return
  end

  print("Testing ESLint CLI on: " .. filename)
  vim.fn.jobstart({"npx", "eslint", filename}, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print("ESLint CLI: " .. line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print("ESLint CLI ERROR: " .. line)
          end
        end
      end
    end,
  })
end

-- Function to check diagnostic display settings
local function check_diagnostic_display()
  print("=== Diagnostic Display Settings ===")

  -- Check diagnostic config
  local diag_config = vim.diagnostic.config()
  print("Diagnostic config:")
  for k, v in pairs(diag_config) do
    print(string.format("  %s: %s", k, vim.inspect(v)))
  end

  -- Check if diagnostics are enabled for current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local enabled = vim.diagnostic.is_enabled(bufnr)
  print(string.format("Diagnostics enabled for buffer %d: %s", bufnr, enabled and "yes" or "no"))

  -- Check diagnostic signs
  print("\nDiagnostic signs:")
  local signs = vim.fn.sign_getdefined()
  if #signs == 0 then
    print("  No diagnostic signs defined!")
  else
    for _, sign in ipairs(signs) do
      if sign.name:match("^Diagnostic") then
        print(string.format("  %s: %s", sign.name, sign.text or ""))
      end
    end
  end

  -- Check signs placed in current buffer
  print("\nSigns in current buffer:")
  local buf_signs = vim.fn.sign_getplaced(bufnr, {group = "*"})
  if buf_signs and buf_signs[1] and buf_signs[1].signs then
    for _, sign in ipairs(buf_signs[1].signs) do
      print(string.format("  Line %d: %s", sign.lnum, sign.name))
    end
  else
    print("  No signs in buffer")
  end

  -- Check virtual text
  print("\nVirtual text check:")
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
  for i, line in ipairs(lines) do
    local virt_text = vim.api.nvim_buf_get_extmarks(bufnr, -1, {i-1, 0}, {i-1, -1}, {type = "virt_text"})
    if #virt_text > 0 then
      print(string.format("  Line %d has virtual text", i))
      for _, extmark in ipairs(virt_text) do
        local details = vim.api.nvim_buf_get_extmark_by_id(bufnr, -1, extmark[1], {details = true})
        if details and details[4] and details[4].virt_text then
          print(string.format("    Text: %s", table.concat(details[4].virt_text, "")))
        end
      end
    end
  end

  -- Check signs column
  print("\nSigns column check:")
  local signcolumn = vim.wo.signcolumn
  print("signcolumn setting: " .. signcolumn)

  -- Check number column
  local number = vim.wo.number
  local relativenumber = vim.wo.relativenumber
  print(string.format("number: %s, relativenumber: %s", number and "yes" or "no", relativenumber and "yes" or "no"))
end

-- Function to enable diagnostics and force show
local function force_enable_diagnostics()
  print("=== Forcing Diagnostic Display ===")

  -- Enable diagnostics globally
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
  })

  -- Enable for current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  vim.diagnostic.enable(bufnr)

  -- Set signcolumn to yes
  vim.wo.signcolumn = "yes"

  print("Diagnostics forcibly enabled. Check if you can see them now.")
end

-- Minimal test: just add a diagnostic and see if it shows
local function minimal_test()
  print("=== Minimal Diagnostic Test ===")

  local bufnr = vim.api.nvim_get_current_buf()

  -- Configure diagnostics
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
  })

  vim.diagnostic.enable(bufnr)
  vim.wo.signcolumn = "yes"

  -- Add a simple test diagnostic on line 1
  local ns_id = vim.diagnostic.get_namespace(bufnr) or 0
  vim.diagnostic.set(ns_id, bufnr, {
    {
      lnum = 0,  -- 0-based line number
      col = 0,   -- 0-based column number
      end_lnum = 0,
      end_col = 5,
      severity = vim.diagnostic.severity.ERROR,
      message = "TEST: This is a visible test diagnostic",
      source = "test",
    }
  })

  vim.cmd("redraw!")

  print("Added test diagnostic on line 1. You should see a red highlight/sign.")
end

-- Function to force show diagnostics - SIMPLIFIED VERSION
local function force_show_diagnostics()
  print("=== Force Show Diagnostics ===")

  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)

  print(string.format("Found %d diagnostics for buffer %d", #diagnostics, bufnr))

  if #diagnostics > 0 then
    print("Existing diagnostics:")
    for i, diag in ipairs(diagnostics) do
      print(string.format("  %d. %s: %s (line %d)", i,
        diag.severity == 1 and "Error" or diag.severity == 2 and "Warning" or "Info",
        diag.message, diag.lnum + 1))
    end
    print("Forced diagnostic display refresh")
  else
    print("No diagnostics found. Running ESLint CLI to generate them...")

    -- Run ESLint manually and add diagnostics
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename ~= "" then
      vim.fn.jobstart({"npx", "eslint", "--format", "json", filename}, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            local json_str = table.concat(data, "")
            if json_str ~= "" then
              local ok, parsed = pcall(vim.json.decode, json_str)
              if ok and parsed and #parsed > 0 then
                print("ESLint found issues, adding diagnostics...")
                local diag_list = {}
                for _, file_result in ipairs(parsed) do
                  if file_result.messages then
                    for _, msg in ipairs(file_result.messages) do
                      table.insert(diag_list, {
                        lnum = msg.line - 1,
                        col = msg.column - 1,
                        end_lnum = msg.endLine and msg.endLine - 1,
                        end_col = msg.endColumn and msg.endColumn - 1,
                        severity = msg.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                        message = msg.message,
                        source = "eslint-manual",
                      })
                    end
                  end
                end
                if #diag_list > 0 then
                  -- Get the namespace for this buffer
                  local ns_id = vim.diagnostic.get_namespace(bufnr) or 0
                  vim.diagnostic.set(ns_id, bufnr, diag_list, {})
                  print("Added " .. #diag_list .. " diagnostics manually")
                  vim.cmd("redraw!")
                else
                  print("ESLint ran but found no issues")
                end
              else
                print("Failed to parse ESLint JSON output")
              end
            end
          else
            print("No ESLint output received")
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            print("ESLint stderr:")
            for _, line in ipairs(data) do
              if line ~= "" then
                print("  " .. line)
              end
            end
          end
        end,
      })
    else
      print("No filename for current buffer")
    end
  end
end

-- Test function to add a fake diagnostic
local function add_test_diagnostic()
  local bufnr = vim.api.nvim_get_current_buf()
  local test_diag = {
    {
      lnum = 0,
      col = 0,
      severity = vim.diagnostic.severity.ERROR,
      message = "TEST DIAGNOSTIC: This is a test error to verify diagnostics are working",
      source = "test",
    }
  }
  
  -- Get namespace for this buffer
  local ns_id = vim.diagnostic.get_namespace(bufnr) or 0
  vim.diagnostic.set(ns_id, bufnr, test_diag, {})
  print("Added test diagnostic. You should see it highlighted in red on line 1.")
  vim.cmd("redraw!")
end

-- Function to check everything at once
local function comprehensive_check()
  print("=== Comprehensive Diagnostic Check ===")

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- 1. Check file
  print("File: " .. filename)

  -- 2. Check LSP clients
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  print("Active LSP clients: " .. #clients)
  for _, client in ipairs(clients) do
    print("  - " .. client.name)
  end

  -- 3. Check diagnostics
  local diags = vim.diagnostic.get(bufnr)
  print("Diagnostics in buffer: " .. #diags)

  -- 4. Check diagnostic config
  local config = vim.diagnostic.config()
  print("Virtual text enabled: " .. tostring(config.virtual_text ~= false))
  print("Signs enabled: " .. tostring(config.signs ~= false))
  print("Underline enabled: " .. tostring(config.underline ~= false))

  -- 5. Check buffer settings
  print("signcolumn: " .. vim.wo.signcolumn)
  print("number: " .. tostring(vim.wo.number))

  -- 6. Test ESLint CLI
  print("\nTesting ESLint CLI...")
  vim.fn.jobstart({"npx", "eslint", filename}, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        print("ESLint CLI output:")
        for _, line in ipairs(data) do
          if line ~= "" then
            print("  " .. line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        print("ESLint CLI errors:")
        for _, line in ipairs(data) do
          if line ~= "" then
            print("  " .. line)
          end
        end
      end
    end,
  })
end

-- Simple test: just add a diagnostic and check if it shows
local function simple_test()
  print("=== Simple Diagnostic Test ===")

  local bufnr = vim.api.nvim_get_current_buf()

  -- Configure diagnostics to ensure they show
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
  })

  -- Enable diagnostics for buffer
  vim.diagnostic.enable(bufnr)

  -- Set signcolumn
  vim.wo.signcolumn = "yes"

  -- Add diagnostic - use vim.lsp.diagnostic as namespace or get it properly
  local ns_id = vim.diagnostic.get_namespace(bufnr) or 0
  
  -- Add diagnostic directly
  vim.diagnostic.set(ns_id, bufnr, {{
    lnum = 0,  -- Line 1 (0-based)
    col = 0,
    end_lnum = 0,
    end_col = 5,
    severity = vim.diagnostic.severity.ERROR,
    message = "TEST: You should see this diagnostic highlighted in red",
  }})

  -- Force display by getting diagnostics and showing them
  local diags = vim.diagnostic.get(bufnr)
  print("Added diagnostic. Count: " .. #diags)
  
  -- Force redraw
  vim.cmd("redraw!")

  print("Test diagnostic added to line 1. You should see:")
  print("1. Red sign in the left column")
  print("2. Red underline under the text")
  print("3. Red virtual text with the error message")
  print("")
  print("If you see this, diagnostics work!")
end

-- Force add ESLint diagnostics manually
local function force_add_eslint_diags()
  print("=== Force Add ESLint Diagnostics ===")

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then
    print("No filename")
    return
  end

  print("Running ESLint on: " .. filename)

  vim.fn.jobstart({"npx", "eslint", "--format", "json", filename}, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        local json_str = table.concat(data, "")
        if json_str ~= "" then
          local ok, parsed = pcall(vim.json.decode, json_str)
          if ok and parsed and #parsed > 0 then
            local diag_count = 0
            for _, file_result in ipairs(parsed) do
              if file_result.messages then
                for _, msg in ipairs(file_result.messages) do
                  diag_count = diag_count + 1
                end
              end
            end

            if diag_count > 0 then
              print("Found " .. diag_count .. " ESLint issues, adding diagnostics...")

              -- Add all ESLint diagnostics
              local diag_list = {}
              for _, file_result in ipairs(parsed) do
                if file_result.messages then
                  for _, msg in ipairs(file_result.messages) do
                    table.insert(diag_list, {
                      lnum = msg.line - 1,
                      col = msg.column - 1,
                      end_lnum = msg.endLine and msg.endLine - 1,
                      end_col = msg.endColumn and msg.endColumn - 1,
                      severity = msg.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                      message = msg.message,
                      source = "eslint-forced",
                    })
                  end
                end
              end

              -- Get namespace for this buffer
              local ns_id = vim.diagnostic.get_namespace(bufnr) or 0
              vim.diagnostic.set(ns_id, bufnr, diag_list, {})

              -- Force redraw
              vim.cmd("redraw!")

              print("Added " .. #diag_list .. " ESLint diagnostics. They should be visible now!")
            else
              print("ESLint ran but found no issues")
            end
          else
            print("Failed to parse ESLint output")
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        print("ESLint error:")
        for _, line in ipairs(data) do
          if line ~= "" then
            print("  " .. line)
          end
        end
      end
    end,
  })
end

vim.api.nvim_create_user_command('DebugLSP', debug_lsp, {})
vim.api.nvim_create_user_command('ForceESLint', force_eslint_check, {})
vim.api.nvim_create_user_command('TestESLint', test_eslint_cli, {})
vim.api.nvim_create_user_command('CheckDiagDisplay', check_diagnostic_display, {})
vim.api.nvim_create_user_command('ShowDiags', force_show_diagnostics, {})
vim.api.nvim_create_user_command('TestDiag', add_test_diagnostic, {})
vim.api.nvim_create_user_command('ForceDiagDisplay', force_enable_diagnostics, {})
vim.api.nvim_create_user_command('CheckAll', comprehensive_check, {})
vim.api.nvim_create_user_command('MinimalTest', minimal_test, {})
vim.api.nvim_create_user_command('SimpleTest', simple_test, {})
vim.api.nvim_create_user_command('ForceAddESLint', force_add_eslint_diags, {})