return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },

  init = function()
    vim.o.autoread = true

    vim.g.opencode_opts = {
      -- valid options only
    }
  end,

  keys = {
    {
      "<leader>aa",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "Opencode Ask",
    },
    {
      "<leader>ax",
      function()
        require("opencode").select()
      end,
      mode = { "n", "x" },
      desc = "Opencode Execute",
    },
    {
      "<leader>at",
      function()
        require("opencode").toggle()
      end,
      mode = { "n", "t" },
      desc = "Opencode Toggle",
    },
  },
}
