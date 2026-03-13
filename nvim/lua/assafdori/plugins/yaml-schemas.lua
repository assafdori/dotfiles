return {
  {
    "b0o/SchemaStore.nvim",
    version = false, -- use latest commit
  },
  {
    -- Recommended by nvim-lspconfig for helm_ls filetype detection
    -- Handles templates/, *.tpl, helmfile.yaml, values*.yaml, commentstring, etc.
    "towolf/vim-helm",
    ft = { "helm", "yaml" }, -- needs yaml to intercept and re-set filetype
  },
  {
    "cwrau/yaml-schema-detect.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "yaml", "helm" }, -- "helm" ft is registered by helm-ls; requires helmls in lsp.lua servers
    opts = {
      keymap = {
        refresh = "<leader>yr", -- Refresh YAML schema detection
        cleanup = "<leader>yc", -- Clean up temporary schema files
        info = "<leader>yi", -- Show schema info for debugging
      },
    },
  },
}
