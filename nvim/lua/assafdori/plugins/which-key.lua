return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    delay = 0,
    height = math.huge,
    icons = {
      group = "", -- default is "+"
      mappings = false, -- disable icons in keymaps
    },
    sort = { "alphanum" },
    spec = {
      { "<leader>a", group = "AI" },
      { "<leader>b", group = "Buffers" },
      { "<leader>d", group = "Diagnostic" },
      { "<leader>f", group = "Files" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Harpoon" },
      { "<leader>l", group = "Code" },
      { "<leader>m", group = "Misc" },
      { "<leader>n", group = "Noice" },
      { "<leader>R", group = "Replace" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Toggles" },
      { "<leader>u", group = "UI" },
      { "<leader>w", group = "Window" },
    },
  },
  config = function(_, opts)
    require("which-key").setup(opts)
  end,
}
