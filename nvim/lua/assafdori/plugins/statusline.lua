return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    -- Custom Lualine component to show attached language server
    local clients_lsp = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })

      if not clients or vim.tbl_isempty(clients) then
        return ""
      end

      local names = {}
      for _, client in ipairs(clients) do
        table.insert(names, client.name)
      end

      return " " .. table.concat(names, "|")
    end

    require("lualine").setup({
      options = {
        component_separators = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "Outline", "snacks_dashboard" },
      },
      sections = {
        lualine_a = {
          { "mode", icon = "" },
        },
        lualine_b = {
          {
            "filetype",
            icon_only = true,
            padding = { left = 1, right = 0 },
          },
          {
            "filename",
            path = 0, -- 0: Just the filename, 1: Relative path, 2: Absolute path
            symbols = { modified = " ", readonly = " " },
          },
        },
        lualine_c = {
          {
            "branch",
            icon = "",
          },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            colored = true,
          },
          {
            "searchcount",
            padding = { left = 1, right = 0 },
            icon = " ",
            count_format = "%d/%d",
          },
          {
            "selectioncount",
            padding = { left = 1, right = 1 },
            icon = " ",
            max_count = 999,
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            update_in_insert = true,
          },
        },
        lualine_y = { clients_lsp },
        lualine_z = {
          { "location", icon = "" },
        },
      },
      inactive_sections = {
        lualine_a = { "filename" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "location" },
      },
      extensions = { "toggleterm", "trouble" },
    })
    vim.api.nvim_set_hl(0, "lualine_a_visual", { fg = "#000000", bg = "#dc4c44", bold = true })
    vim.api.nvim_set_hl(0, "lualine_a_replace", { fg = "#000000", bg = "#dc4c44", bold = true })
    vim.api.nvim_set_hl(0, "lualine_a_command", { fg = "#000000", bg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "lualine_a_insert", { fg = "#000000", bg = "#a6e3a1", bold = true })
  end,
}
