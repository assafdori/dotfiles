local servers = {
  bashls = {},
  dockerls = {},
  gopls = {
    settings = {
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        fieldalignment = true,
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
  lua_ls = {
    -- cmd = { ... },
    -- filetypes = { ... },
    -- capabilities = {},
    settings = {
      format = {
        enable = false, -- let conform handle the formatting
      },
      diagnostics = { globals = { "vim" } },
      telemetry = { enable = false },
      hint = { enable = true },
      Lua = {
        workspace = {
          checkThirdParty = false,
        },
        codeLens = {
          enable = true,
        },
        doc = {
          privateName = { "^_" },
        },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        completion = {
          callSnippet = "Replace",
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  marksman = {},
  pyright = {},
  helm_ls = {},
  terraformls = {},
  tinymist = {},
  yamlls = function()
    -- Use SchemaStore.nvim for automatic schema management
    local schemastore_ok, schemastore = pcall(require, "schemastore")

    return {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
          schemaStore = {
            -- Disable built-in schemaStore to use SchemaStore.nvim
            -- Also required by yaml-schema-detect.nvim
            enable = false,
            url = "",
          },
          format = { enabled = false }, -- Let conform.nvim handle formatting
          validate = true,
          -- Use SchemaStore.nvim for comprehensive schema catalog
          -- yaml-schema-detect.nvim will dynamically override these per-buffer
          -- for Kubernetes resources based on apiVersion/kind detection
          schemas = schemastore_ok and schemastore.yaml.schemas() or {},
        },
      },
    }
  end,
}
local tools = {
  "debugpy",
  "delve",
  "gofumpt",
  "goimports",
  "golangci-lint",
  "gomodifytags",
  "gotests",
  "hadolint",
  "iferr",
  "impl",
  "isort",
  "markdownlint-cli2",
  "prettier",
  "ruff",
  "selene",
  "shellcheck",
  "shfmt",
  "stylua",
  "taplo",
  "tflint",
  "typstfmt",
  "yamllint",
  "terraform-ls",
  "bash-language-server",
}

-- TODO: Maybe replace Mason with "pure" nvim-lspconfig
return {

  { "williamboman/mason.nvim", config = true, lazy = true }, -- NOTE: Must be loaded before dependants
  { "williamboman/mason-lspconfig.nvim", lazy = true },
  { "WhoIsSethDaniel/mason-tool-installer.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- BUG: Prevents new tools from being installed!
    config = function()
      -- function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          map("<leader>lk", vim.lsp.buf.hover, "Hover")
          map("<leader>lR", vim.lsp.buf.rename, "Rename")
          map("<leader>la", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          map("<leader>lD", vim.lsp.buf.declaration, "Declaration")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end
        end,
      })

      local signs = { ERROR = "", WARN = "", INFO = "", HINT = "" }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config({ signs = { text = diagnostic_signs } })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

      require("mason").setup()

      -- mason-tool-installer handles non-LSP tools (formatters, linters, etc.)
      -- mason-lspconfig handles LSP servers and translates lspconfig names to Mason package names
      require("mason-tool-installer").setup({ ensure_installed = tools })

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- Support function-based server configs (e.g., for dynamic SchemaStore.nvim integration)
            if type(server) == "function" then
              server = server()
            end
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
}
