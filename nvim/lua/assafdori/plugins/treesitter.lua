local langs = {
  "bash",
  "cmake",
  "css",
  "dockerfile",
  "go",
  "hcl",
  "html",
  "java",
  "javascript",
  "json",
  "kotlin",
  "ledger",
  "lua",
  "markdown",
  "markdown_inline",
  "query",
  "python",
  "regex",
  "terraform",
  "toml",
  "vim",
  "yaml",
}

return {
  "neovim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" },
  lazy = false,
  build = ":TSUpdate",
  opts = {
    install_dir = vim.fn.stdpath("data") .. "/site",
  },
  config = function(_, opts)
    local ts = require("nvim-treesitter")
    ts.setup(opts)
    ts.install(langs)
  end,
}
