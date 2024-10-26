return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    { "j-hui/fidget.nvim",       opts = {} },
    { "b0o/schemastore.nvim" },
    { "hrsh7th/cmp-nvim-lsp" },
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(require("plugins.lsp.servers")),
    })
    require("lspconfig.ui.windows").default_options.border = "single"

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(event)
        -- Keymap setup (unchanged)
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup_handlers({
      function(server_name)
        if server_name == "yamlls" then
          require("lspconfig").yamlls.setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              client.server_capabilities.documentFormattingProvider = true -- Add this line for YAML formatting
              -- If you have an external on_attach function, call it here
              -- on_attach(client, bufnr)  -- Uncomment if necessary
            end,
            flags = {
              debounce_text_changes = 150,
            },
            settings = {
              yaml = {
                format = {
                  enable = true,
                },
                schemaStore = {
                  enable = true, -- Use built-in schema store for convenience
                },
                schemas = {
                  kubernetes = { "k8s*.yaml", "k8s*.yml" }, -- Apply Kubernetes schemas to all YAML files
                  ["http://json.schemastore.org/kustomization"] = "kustomization.yaml", -- Apply Kustomization schema to Kustomization files
                  ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                  ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
                  ["http://json.schemastore.org/ansible"] = "ansible*.yaml",
                  ["http://json.schemastore.org/ansible-role"] = "ansible-role*.yaml",
                  ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
                  ["http://json.schemastore.org/stylelintrc"] = ".stylelintrc.{yml,yaml}",
                  ["http://json.schemastore.org/commitlint"] = ".commitlintrc.{yml,yaml}",

                },
              },
            },
          })
        else
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            settings = require("plugins.lsp.servers")[server_name],
            filetypes = (require("plugins.lsp.servers")[server_name] or {}).filetypes,
          })
        end
      end,
    })

    -- Other LSP and diagnostics configuration (unchanged)
  end,
}
