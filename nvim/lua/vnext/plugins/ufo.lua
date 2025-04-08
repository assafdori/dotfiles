-- Setup ufo: kevinhwang91/nvim-ufo
return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  config = function()
    require("ufo").setup({
      open_fold_hl_timeout = 0, -- Disable automatic fold highlighting
      provider_selector = function(_, _, _)
        return { "treesitter", "indent" } -- Use Treesitter and indent as fallback
      end,
    })
    vim.o.foldlevel = 99 -- Ensure folds are open by default
    vim.o.foldlevelstart = 99 -- Start with all folds open
    vim.o.foldenable = true -- Enable folding
    -- vim.o.foldcolumn = "1" -- Show fold column
  end,
}
