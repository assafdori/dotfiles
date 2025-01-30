return {
  "numToStr/Navigator.nvim",
  opts = {},
  keys = {
    { "<C-h>", "<cmd>lua require('Navigator').left()<CR>" },
    { "<C-k>", "<cmd>lua require('Navigator').up()<CR>" },
    { "<C-l>", "<cmd>lua require('Navigator').right()<CR>" },
    { "<C-j>", "<cmd>lua require('Navigator').down()<CR>" },
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        stop_eof = true,
        easing_function = "sine",
        hide_cursor = true,
        cursor_scrolls_alone = true,
      })
    end,
  },
}
