return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            -- jump_next = "<c-j>",
            -- jump_prev = "<c-k>",
            accept = "<c-a>",
            refresh = "r",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<c-t>",
            accept_word = false,
            accept_line = false,
            next = "<c-j>",
            prev = "<c-k>",
            dismiss = "<C-e>",
          },
        },
        filetypes = {
          yaml = true,
        },
      })

      -- Custom Tab keybinding for Copilot
      -- Accept Copilot suggestion with Tab, but only when Copilot has a suggestion
      -- Otherwise, let Tab behave normally (e.g., for completion navigation)
      vim.keymap.set("i", "<Tab>", function()
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").accept()
        else
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "i")
        end
      end, { desc = "Accept Copilot suggestion or fallback to Tab" })
    end,
  },
}
