return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()
  end,
  keys = {
    {
      "<leader>ha",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Add file to Harpoon",
    },
    {
      "<leader>hh",
      function()
        require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
      end,
      desc = "Toggle Harpoon menu",
    },
  },
}
