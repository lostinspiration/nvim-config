return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function()
    vim.keymap.set("n", "pc", function()
      require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true })
  end
}
