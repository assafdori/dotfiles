-- TODO: profiler

---@module 'snacks'

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    explorer = {
      layout = {
        cycle = false,
      },
    },
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = "", key = "f", desc = "find file", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "", key = "n", desc = "new file", action = ":ene | startinsert" },
          { icon = "", key = "g", desc = "grep text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = "", key = "r", desc = "recent file", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = "", key = "c", desc = "config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",},
          { icon = "󰴽", key = "s", desc = "session", section = "session" },
          { icon = "󰒲", key = "L", desc = "lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = "󰈆", key = "q", desc = "quit", action = ":qa" },
        },
        header = [[
    ____           __                   ____           __  
   / __/___ ______/ /_   ____ ______   / __/_  _______/ /__
  / /_/ __ `/ ___/ __/  / __ `/ ___/  / /_/ / / / ___/ //_/
 / __/ /_/ (__  ) /_   / /_/ (__  )  / __/ /_/ / /__/ ,<   
/_/  \__,_/____/\__/   \__,_/____/  /_/  \__,_/\___/_/|_|  
       __                                                  
      / /_  ____  ____  ____  ____  __  ____  ____  __     
     / __ \/ __ \/ __ \/ __ \/ __ \/ / / / / / / / / /     
    / /_/ / /_/ / /_/ / /_/ / /_/ / /_/ / /_/ / /_/ /      
   /_.___/\____/\____/\____/\____/\__, /\__, /\__, /       
                                 /____//____//____/        
]],
      },
      formats = {
        header = {
          align = "center",
        },
      },
      sections = {
        {
          section = "header",
          padding = 6,
        },
        {
          pane = 2,
          padding = 1,
          {
            { section = "keys", gap = 1, padding = 1 },
            { section = "startup", icon = "󱐌 ", gap = 1, padding = 1 },
          },
        },
      },
    },
    dim = { enabled = true },
    win = {
      backdrop = { transparent = true, blend = 100 },
    },
    lazygit = {
      enabled = true,
      win = {
        border = "rounded",
        backdrop = { transparent = true, blend = 100 },
      },
    },
    indent = {
      enabled = true,
      indent = { only_scope = false }, -- only show indent where cursor is
      chunk = { enabled = true }, -- indents are rendered as chunks
      animate = { enabled = true }, -- do not animate -- feels slow for me
    },
    notifier = {
      enabled = true,
      timeout = 2000,
    },
    picker = {
      ui_select = true,
      ignored = true,
      layout = {
        cycle = false,
      },
      sources = {
        explorer = { hidden = true, win },
        files = { hidden = true },
        grep = { hidden = true },
      },
      win = {
        input = {
          keys = {
            -- NOTE: quick close picker/fuzzy finder
            -- ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
          },
        },
      },
    },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
  },
  keys = {
    -- stylua: ignore start

    -- ╭───────────────────────╮
    -- │ 📁 File Management    │
    -- ╰───────────────────────╯
    { "<leader>fR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },

    -- ╭───────────────────────╮
    -- │ 🔍 Search / Pickers   │
    -- ╰───────────────────────╯
    { "<C-s>",      function() Snacks.picker.lines():set_layout("ivy") end, desc = "Search Current File", mode = { "n", "x" } },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    { "<leader>ff", function() Snacks.picker.smart({ filter = { cwd = true } }):set_layout("ivy") end, desc = "Smart Find" },
    { "<leader>sf", function() Snacks.picker.files() end, desc = "Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>ss", function() Snacks.picker.grep():set_layout("ivy") end, desc = "Strings" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep Words" },
    { "<leader>sl", function() Snacks.picker.lines() end, desc = "Buffer Fuzzy" },
    { "<leader>sb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>sk", function() Snacks.picker.keymaps():set_layout("ivy") end, desc = "Keymaps" },
    { "<leader>sh", function() Snacks.picker.help():set_layout("ivy") end, desc = "Help" },
    { "<leader>sd", function() Snacks.picker.diagnostics():set_layout("ivy") end, desc = "Diagnostics" },
    { "<leader>sz", function() Snacks.picker.zoxide():set_layout("ivy") end, desc = "Zoxide" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo" },
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo", },

    -- ╭───────────────────────╮
    -- │ 🧠 LSP               │
    -- ╰───────────────────────╯
    { "<leader>ld", function() Snacks.picker.lsp_definitions():set_layout("ivy") end, desc = "Definition" },
    { "<leader>lr", function() Snacks.picker.lsp_references():set_layout("ivy") end, nowait = true, desc = "References" },
    { "<leader>lt", function() Snacks.picker.lsp_type_definitions():set_layout("ivy") end, desc = "Type Definition" },
    { "<leader>lI", function() Snacks.picker.lsp_implementations():set_layout("ivy") end, desc = "Implementation" },
    { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
    { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },

    -- ╭───────────────────────╮
    -- │ 🧬 Git               │
    -- ╰───────────────────────╯
    { "<leader>gx", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    -- { "<leader>gB", function() Snacks.git.blame_line() end, desc = "Git Blame" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    { "<leader>gL", function() Snacks.picker.git_log_line():set_layout("ivy") end, desc = "Git Log Line" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },

    -- ╭───────────────────────╮
    -- │ 🖥️ Terminal / Tools  │
    -- ╰───────────────────────╯
    { "<leader>tt", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<leader>te", function() Snacks.picker.explorer() end, desc = "Toggle Explorer" },

    -- ╭───────────────────────╮
    -- │ 🧘 UI / Zen / UX     │
    -- ╰───────────────────────╯
    { "<leader>uZ", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>uz", function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    { "<leader>nn", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  },
  -- stylua: ignore end
  init = function()
    -- Set up terminal-mode navigation for Snacks terminal buffers
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        -- Check if this is a Snacks terminal
        local buf_name = vim.api.nvim_buf_get_name(0)
        if buf_name:match("snacks_terminal") or vim.bo.filetype == "snacks_terminal" then
          -- Set up terminal-mode navigation mappings for all directions
          vim.keymap.set(
            "t",
            "<C-h>",
            "<cmd>TmuxNavigateLeft<cr>",
            { buffer = true, desc = "Navigate left (terminal)" }
          )
          vim.keymap.set(
            "t",
            "<C-j>",
            "<cmd>TmuxNavigateDown<cr>",
            { buffer = true, desc = "Navigate down (terminal)" }
          )
          vim.keymap.set("t", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { buffer = true, desc = "Navigate up (terminal)" })
          vim.keymap.set(
            "t",
            "<C-l>",
            "<cmd>TmuxNavigateRight<cr>",
            { buffer = true, desc = "Navigate right (terminal)" }
          )
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- stylua: ignore start
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>un")
        Snacks.toggle.option("cursorline", { name = "Cursorline" }):map("<leader>uC")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.dim():map("<leader>uD")
        -- stylua: ignore end
      end,
    })
  end,
}
