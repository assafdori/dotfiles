return {
  {
    "nvim-mini/mini.files",
    config = function()
      local MiniFiles = require("mini.files")

      MiniFiles.setup({
        windows = {
          preview = true,
          width_focus = 32,
          width_preview = 48,
        },
        options = {
          use_as_default_explorer = true,
          permanent_delete = false,
        },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          if vim.bo[buf_id].filetype ~= "minifiles" then
            return
          end

          -- Allow `:write` on explorer buffers via `BufWriteCmd`
          vim.bo[buf_id].buftype = "acwrite"

          local go_in_and_close = function()
            MiniFiles.go_in({ close_on_file = true })
          end

          local go_in_split = function(split_cmd)
            local entry = MiniFiles.get_fs_entry()
            if not entry then
              return
            end
            if entry.fs_type == "directory" then
              MiniFiles.go_in()
              return
            end

            local state = MiniFiles.get_explorer_state()
            local target_win = state and state.target_window or nil

            if target_win and vim.api.nvim_win_is_valid(target_win) then
              vim.api.nvim_win_call(target_win, function()
                vim.cmd(split_cmd)
                MiniFiles.set_target_window(vim.api.nvim_get_current_win())
              end)
            else
              vim.cmd(split_cmd)
              MiniFiles.set_target_window(vim.api.nvim_get_current_win())
            end

            MiniFiles.go_in({ close_on_file = true })
          end

          vim.keymap.set("n", "l", go_in_and_close, { buffer = buf_id, desc = "Open (close explorer)" })
          vim.keymap.set("n", "<CR>", go_in_and_close, { buffer = buf_id, desc = "Open (close explorer)" })
          vim.keymap.set("n", "<C-v>", function()
            go_in_split("vsplit")
          end, { buffer = buf_id, desc = "Open in vertical split (close explorer)" })
          vim.keymap.set("n", "<C-s>", function()
            go_in_split("split")
          end, { buffer = buf_id, desc = "Open in horizontal split (close explorer)" })

          vim.api.nvim_create_autocmd("BufWriteCmd", {
            buffer = buf_id,
            callback = function()
              local did_sync = MiniFiles.synchronize()
              if did_sync then
                vim.bo[buf_id].modified = false
              end
            end,
            desc = "mini.files: sync changes on :write",
          })
        end,
      })

      local function is_open()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "minifiles" then
            return true
          end
        end
        return false
      end

      local function toggle(path)
        if is_open() then
          MiniFiles.close()
          return
        end
        MiniFiles.open(path, true)
      end

      vim.keymap.set("n", "<leader>te", function()
        toggle(nil)
      end, { desc = "Toggle Explorer" })

      vim.keymap.set("n", "<leader>tE", function()
        local path = vim.api.nvim_buf_get_name(0)
        toggle(path ~= "" and path or nil)
      end, { desc = "Toggle Explorer (buf file)" })
    end,
  },
}
