return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = function()
      local icons = require("assafdori.config.icons") -- update this path if different
      local prompts = require("CopilotChat.config.prompts")
      local select = require("CopilotChat.select")

      local COPILOT_PLAN = [[
        You are a software architect and technical planner focused on clear, actionable development plans.
      ]] .. prompts.COPILOT_BASE.system_prompt .. [[

      When creating development plans:
      - Start with a high-level overview
      - Break down into concrete implementation steps
      - Identify potential challenges and their solutions
      - Consider architectural impacts
      - Note required dependencies or prerequisites
      - Estimate complexity and effort levels
      - Track confidence percentage (0-100%)
      - Format in markdown with clear sections

      Always end with:
      "Current Confidence Level: X%"
      "Would you like to proceed with implementation?" (only if confidence >= 90%)
      ]]

      return {
        model = "claude-3.7-sonnet",
        references_display = "write",
        debug = false,
        question_header = " " .. icons.ui.User .. " ",
        answer_header = " " .. icons.ui.Bot .. " ",
        error_header = "> " .. icons.diagnostics.Warn .. " ",
        selection = select.visual,
        context = "buffers",
        mappings = {
          reset = false,
          show_diff = {
            full_diff = true,
          },
        },
        prompts = {
          Explain = { mapping = "<leader>ae", description = "AI Explain" },
          Review = { mapping = "<leader>ar", description = "AI Review" },
          Tests = { mapping = "<leader>at", description = "AI Tests" },
          Fix = { mapping = "<leader>af", description = "AI Fix" },
          Optimize = { mapping = "<leader>ao", description = "AI Optimize" },
          Docs = { mapping = "<leader>ad", description = "AI Documentation" },
          Commit = {
            mapping = "<leader>ac",
            description = "AI Generate Commit",
            selection = select.buffer,
          },
          Plan = {
            prompt = "Create or update the development plan for the selected code. Focus on architecture, implementation steps, and potential challenges.",
            system_prompt = COPILOT_PLAN,
            context = "file:.copilot/plan.md",
            progress = function()
              return false
            end,
            callback = function(response, source)
              require("CopilotChat").chat:append("Plan updated successfully!", source.winnr)
              local plan_file = source.cwd() .. "/.copilot/plan.md"
              local dir = vim.fn.fnamemodify(plan_file, ":h")
              vim.fn.mkdir(dir, "p")
              local file = io.open(plan_file, "w")
              if file then
                file:write(response)
                file:close()
              end
            end,
          },
        },
      }
    end,
    keys = {
      {
        "<leader>aa",
        function()
          require("CopilotChat").toggle()
        end,
        desc = "AI Toggle",
      },
      {
        "<leader>ax",
        function()
          require("CopilotChat").reset()
        end,
        desc = "AI Reset",
      },
      {
        "<leader>as",
        function()
          require("CopilotChat").stop()
        end,
        desc = "AI Stop",
      },
      {
        "<leader>am",
        function()
          require("CopilotChat").select_model()
        end,
        desc = "AI Models",
      },
      {
        "<leader>ag",
        function()
          require("CopilotChat").select_agent()
        end,
        desc = "AI Agents",
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "AI Prompts",
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({ prompt = "AI Question> " }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "AI Question",
        mode = { "n", "v" },
      },
    },
  },
}
