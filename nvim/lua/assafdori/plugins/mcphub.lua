return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
  },
  event = "VeryLazy", -- Load earlier for better availability
  build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
  config = function()
    require("mcphub").setup({
      -- Add specific MCP server configurations here
      servers = {
        -- Add commonly used servers
        github = {
          auto_start = true, -- Auto-start GitHub server
        },
        neovim = {
          auto_start = true, -- Auto-start Neovim server
        },
      },
    })
  end,
}
