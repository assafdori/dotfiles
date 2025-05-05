return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  build = "make",
  config = function()
    require("avante").setup({
      provider = "copilot", -- The provider used in Aider mode or in the planning phase of Cursor Planning Mode
      copilot = {
        model = "claude-3.5-sonnet",
      },
      disabled_tools = {
        -- "rag_search",
        -- "python",
        -- "git_diff",
        -- "git_commit",
        -- "list_files",
        -- "search_files",
        -- "search_keyword",
        -- "read_file_toplevel_symbols",
        -- "read_file",
        --"create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        -- "bash",
        -- "web_search",
        -- "fetch",
      },
      -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
      system_prompt = function()
        local ok, mcphub = pcall(require, "mcphub")
        if not ok then
          return "mcphub not available"
        end
        local hub = mcphub.get_hub_instance()
        if not hub or type(hub.get_active_servers_prompt) ~= "function" then
          return "no active servers"
        end
        return hub:get_active_servers_prompt()
      end,
      -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
      custom_tools = function()
        local ok, ext = pcall(require, "mcphub.extensions.avante")
        if not ok or type(ext.mcp_tool) ~= "function" then
          return {}
        end
        return {
          ext.mcp_tool(),
        }
      end,
    })
  end,
}
