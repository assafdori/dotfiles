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
        header = [[
██████╗ ██████╗ ██╗███████╗████████╗    ██╗  ██╗ █████╗ ██████╗ ██████╗ ███████╗███╗   ██╗███████╗
██╔══██╗██╔══██╗██║██╔════╝╚══██╔══╝    ██║  ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝
██║  ██║██████╔╝██║█████╗     ██║       ███████║███████║██████╔╝██████╔╝█████╗  ██╔██╗ ██║███████╗
██║  ██║██╔══██╗██║██╔══╝     ██║       ██╔══██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██║╚██╗██║╚════██║
██████╔╝██║  ██║██║██║        ██║       ██║  ██║██║  ██║██║     ██║     ███████╗██║ ╚████║███████║
╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝        ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═══╝╚══════╝
          ]],
      },
      -- preset = {
      --   ---@type snacks.dashboard.Item[]
      --   -- stylua: ignore start
      --   keys = {
      --     { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.smart({filter = {cwd = true}})" },
      --     { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      --     { icon = " ", key = "s", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
      --     { icon = " ", key = "b", desc = "File browser", action = function()  require("yazi").yazi(nil, vim.fn.getcwd()) end,},
      --     { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy check", enabled = package.loaded.lazy },
      --     { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      --     -- stylua: ignore end
      --   },
      -- },
      -- sections = {
      --   { section = "header" },
      --   { section = "keys", gap = 1 },
      --   { title = "\nRecent Files", section = "recent_files", indent = 1, padding = { 2, 1 } },
      --   { title = "Projects", section = "projects", indent = 1, padding = { 2, 1 } },
      --   {
      --     icon = " ",
      --     title = "Git Status",
      --     section = "terminal",
      --     enabled = function()
      --       return Snacks.git.get_root() ~= nil
      --     end,
      --     cmd = "git status --short --branch --renames",
      --     height = 5,
      --     padding = 1,
      --     ttl = 5 * 60,
      --     indent = 3,
      --   },
      --   { section = "startup" },
      -- },
    },
    dim = { enabled = true },
    lazygit = { enabled = true },
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
      layout = {
        cycle = false,
      },
      sources = {
        explorer = { hidden = true },
        files = { hidden = true },
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
    { "<C-s>",      function() Snacks.picker.lines() end, desc = "Search Current File", mode = { "n", "x" } },
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
    { "<leader>gm", function() Snacks.picker.git_status() end, desc = "Git Modified" },
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    { "<leader>gL", function() Snacks.picker.git_log_line():set_layout("ivy") end, desc = "Git Log Line" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },

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
