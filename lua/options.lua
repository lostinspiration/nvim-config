-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.o.rnu = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- tab/space format
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.g.rust_recommended_style = false

-- folding
local ident = 0
function MakeFolds()
  local tmp = ident
  local line = vim.fn.getline(vim.v.lnum)
  if line:match('{') and line:match('}') then
    return tmp
  end
  if line:match('{') then
    ident = ident + 1
    tmp = ident
  end
  if line:match('}') then
    tmp = ident
    ident = ident - 1
  end

  return tmp
end

function FoldText()
  local fs = vim.v.foldstart
  local line = vim.fn.getline(fs)
  local spaces = string.rep(' ', vim.o.tabstop)
  return vim.fn.substitute(line, '\t', spaces, 'g')
end

vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'expr'
vim.opt.foldcolumn = '1'
vim.opt.foldexpr = 'v:lua.MakeFolds()'
vim.opt.foldtext = 'v:lua.FoldText()'

-- vim: ts=2 sts=2 sw=2 et
