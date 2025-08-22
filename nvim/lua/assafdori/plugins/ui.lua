return {

  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      -- From https://github.com/LazyVim/LazyVim/blob/5115b585e7df4cedb519734ffc380b7e48a366f1/lua/lazyvim/util/mini.lua
      -- From https://github.com/LazyVim/LazyVim/blob/d35a3914bfc0c7c1000184585217d58a81f5da1a/lua/lazyvim/plugins/ui.lua#L310
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" }) -- no background for dropbar
    end,
  },

  {
    "mikavilpas/yazi.nvim",
    lazy = true, -- use `event = "VeryLazy"` for netrw replacement
    keys = {
      {
        "<leader>t-",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Toggle Yazi",
      },
      { "<leader>tf", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Toggle Yazi for Current File" },
    },
    opts = {
      open_for_directories = false,
    },
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    -- dependencies = {
    --   { "rcarriga/nvim-notify" },
    -- },
    keys = {
      { "<leader>no", "<cmd>Noice all<cr>", desc = "Open Noice" },
    },
    opts = {
      cmdline = {
        -- view = "cmdline", -- classic cmdline at the botton
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          -- ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      presets = {
        command_palette = true,
        bottom_search = true, -- use a classic bottom cmdline for search
        long_message_to_split = true, -- long messages will be sent to a split
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },

  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" }, -- Enable on file open
    keys = {
      { "<leader>ux", "<cmd>ColorizerToggle<cr>", desc = "Toggle Colorizer" },
    },
    opts = {}, -- if you want to pass config options
    config = function(_, opts)
      require("colorizer").setup(nil, opts) -- enable for all filetypes by default
    end,
  },

  {
    "assafdori/ssshhh",
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme("no-clown-fiesta")
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2A2A2A", underline = false })
      vim.api.nvim_set_hl(0, "@keyword", { fg = "#b46958", bold = true })
      vim.api.nvim_set_hl(0, "@type", { fg = "#BAD7FF" })
      vim.api.nvim_set_hl(0, "@property", { fg = "#88afa2" })
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#dddddd", bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#dc4c44", bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = "#dddddd", italic = true })
    end,
  },
  {
    "mcauley-penney/visual-whitespace.nvim",
    config = true,
    event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
    opts = {},
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },
}
