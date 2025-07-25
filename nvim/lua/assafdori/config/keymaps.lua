-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle between dark and light theme
vim.keymap.set("n", "<leader>ut", function()
  vim.cmd("ToggleTheme")
end, { desc = "Toggle dark/light theme" })

local function map(mode, l, r, opts)
  opts = opts or {}
  vim.keymap.set(mode, l, r, opts)
end

-- Remap for dealing with visual line wraps
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Easy right-left navigation
vim.keymap.set({ "n", "x", "o" }, "H", "^", opts)
vim.keymap.set({ "n", "x", "o" }, "L", "g_", opts)

-- Indenting
map("v", "<", "<gv", { desc = "Unindent selected lines" })
map("v", ">", ">gv", { desc = "Indent selected lines" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selected lines up" })

-- Cancel search highlighting with ESC
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch and ESC" })
map({ "i" }, "<C-c>", "<esc>", { desc = "Clear hlsearch and ESC" })

-- Press jj or jk to escape from insert mode
map("i", "jj", "<esc>", { desc = "Escape from insert mode" })
map("i", "jk", "<esc>", { desc = "Escape from insert mode" })

-- window
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close" })
map("n", "<leader>wT", "<cmd>wincmd T<cr>", { desc = "Move window to new tab" })
map("n", "<leader>wr", "<cmd>wincmd r<cr>", { desc = "rotate down/right" })
map("n", "<leader>wR", "<cmd>wincmd R<cr>", { desc = "rotate up/left" })
map("n", "<leader>wH", "<cmd>wincmd H<cr>", { desc = "Move left" })
map("n", "<leader>wJ", "<cmd>wincmd J<cr>", { desc = "Move down" })
map("n", "<leader>wK", "<cmd>wincmd K<cr>", { desc = "Move up" })
map("n", "<leader>wL", "<cmd>wincmd L<cr>", { desc = "Move right" })
map("n", "<leader>w=", "<cmd>wincmd =<cr>", { desc = "Equalize size" })

-- Repeatable keybinds
map("n", "<M-h>", "<cmd>vertical resize -2<cr>", { desc = "← shrink width" })
map("n", "<M-l>", "<cmd>vertical resize +2<cr>", { desc = "→ grow width" })
map("n", "<M-k>", "<cmd>resize -2<cr>", { desc = "↑ shrink height" })
map("n", "<M-j>", "<cmd>resize +2<cr>", { desc = "↓ grow height" })

-- buffers
map("n", "<tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>bD", "<cmd>%bd|e#|bd#<cr>", { desc = "Close all but the current buffer" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
-- save file
map("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save file" })
-- open path under cursor
map("n", "<leader>fo", "gf", { desc = "Open path under cursor" })

-- diagnostics
-- stylua: ignore start
map("n", "<leader>dj", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next Diagnostic" })
map("n", "<leader>dk", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev Diagnostic" })
map("n", "<leader>dc", function() vim.diagnostic.open_float() end, { desc = "Toggle current diagnostic" })
map("n", "<leader>dd", function() vim.diagnostic.setqflist() end, { desc = "Open quickfix" })
-- stylua: ignore end

-- move over a closing element in insert mode
map("i", "<C-l>", function()
  local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local after = line:sub(col + 1, -1)
  local closer_col = #after + 1
  local closer_i = nil
  for i, closer in ipairs(closers) do
    local cur_index, _ = after:find(closer)
    if cur_index and (cur_index < closer_col) then
      closer_col = cur_index
      closer_i = i
    end
  end
  if closer_i then
    vim.api.nvim_win_set_cursor(0, { row, col + closer_col })
  else
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
  end
end, { desc = "move over a closing element" })

-- Disable default mappings to declutter which-key
-- vim.api.nvim_del_keymap("n", "gra") -- vim.lsp.buf...
-- vim.api.nvim_del_keymap("x", "gra") -- vim.lsp.buf...
-- vim.api.nvim_del_keymap("n", "gri") -- vim.lsp.buf...
-- vim.api.nvim_del_keymap("n", "grn") -- vim.lsp.buf...
-- vim.api.nvim_del_keymap("n", "grr") -- vim.lsp.buf...
-- vim.api.nvim_del_keymap("n", "gO") -- vim.lsp.buf...
--
-- vim.api.nvim_del_keymap("n", "]d") -- vim.lsp.buf...
-- vim.api.nvim_del_keymap("n", "]D") -- vim.lsp.buf...
--
-- vim.api.nvim_del_keymap("n", "gx") -- open filepath under cursor
-- vim.api.nvim_del_keymap("x", "gx") -- open filepath under cursor
