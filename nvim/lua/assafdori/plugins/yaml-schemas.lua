return {
  {
    "b0o/SchemaStore.nvim",
    version = false, -- use latest commit
    validate = true,
    lazy = true,
  },
  {
    "cwrau/yaml-schema-detect.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "yaml", "helm" },
    opts = {
      keymap = {
        refresh = "<leader>yr", -- Refresh YAML schema detection
        cleanup = "<leader>yc", -- Clean up temporary schema files
        info = "<leader>yi", -- Show schema info for debugging
      },
    },
  },
}
