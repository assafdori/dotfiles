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

    -- Set up terminal-mode navigation for opencode buffers
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        -- Check if this is an opencode terminal
        -- We'll detect this by checking if the buffer name contains "opencode"
        local buf_name = vim.api.nvim_buf_get_name(0)
        if buf_name:match("opencode") or vim.bo.filetype == "opencode" then
          -- Set up terminal-mode navigation mappings for this buffer
          vim.keymap.set("t", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { buffer = true, desc = "Navigate left (opencode)" })
          vim.keymap.set("t", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { buffer = true, desc = "Navigate down (opencode)" })
          vim.keymap.set("t", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { buffer = true, desc = "Navigate up (opencode)" })
          vim.keymap.set("t", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { buffer = true, desc = "Navigate right (opencode)" })
        end
      end,
    })
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
