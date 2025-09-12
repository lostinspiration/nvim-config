vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ options ]]
-- set highlight on search
vim.o.hlsearch = false

-- make line numbers default
vim.wo.number = true
vim.o.rnu = true

-- enable mouse mode
vim.o.mouse = 'a'

-- sync clipboard between os and nvim
vim.o.clipboard = 'unnamedplus'

-- enable break indent
vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

-- case insensitive searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- decrese update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- tab/space format
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.g.rust_recommended_style = false

-- [[ keymaps ]]

vim.keymap.set({ 'n', 'v' }, '<space>', '<Nop>', { silent = true })

-- dont touch unnamed register when pasting over visual selection
vim.keymap.set('v', 'p', '"_dP', { silent = true, noremap = true })

-- remap for dealing with wordwrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- move lines
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
vim.keymap.set('v', '<A-j>', ':m \'>+1<CR>==gv')
vim.keymap.set('v', '<A-k>', ':m \'<-2<CR>==gv')

-- diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ packages ]]
vim.pack.add({
  {
    src = 'https://github.com/nvim-lua/plenary.nvim',
    version = 'v0.1.4',
  },
  {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    version = '0.1.8',
    data = {
      config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        local themes = require('telescope.themes')

        telescope.setup({
          defaults = {
            mappings = {
              i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
              },
            },
          },
          extensions = {
            file_browser = {
              theme = 'ivy',
              -- disable netrw and use telescope-file-browser in its place
              hijack_netrw = true,
            },
          },
        })

        pcall(telescope.load_extension, 'fzf')
        pcall(telescope.load_extension, 'file_browser')

        -- see `:help telescope.builtin`
        vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
        vim.keymap.set('n', '<leader>/', function()
          builtin.current_buffer_fuzzy_find(themes.get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end, { desc = '[/] Fuzzily search in current buffer' })
        vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>fb', ':Telescope file_browser<CR>', { noremap = true })
        vim.keymap.set('n', '<leader>fc', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', { noremap = true })
      end
    },
  },
  {
    src = 'https://github.com/nvim-telescope/telescope-file-browser.nvim',
  },
  {
    src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  },
  {
    src = 'https://github.com/neovim/nvim-lspconfig',
    version = 'v2.4.0',
  },
  {
    src = 'https://github.com/mason-org/mason.nvim',
    version = 'v2.0.1',
    data = {
      config = function()
        require('mason').setup()
      end
    },
  },
  {
    src = 'https://github.com/ThePrimeagen/harpoon',
    version = 'harpoon2',
    data = {
      config = function()
        local harpoon = require('harpoon')
        harpoon:setup()

        vim.keymap.set('n', '<leader>ha', function()
          harpoon:list():add()
        end)
        vim.keymap.set('n', '<leader>he', function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end)
      end
    },
  },
  {
    src = 'https://github.com/navarasu/onedark.nvim',
    data = {
      config = function()
        local onedark = require('onedark')
        onedark.setup()
        onedark.load()
      end
    },
  },
  {
    src = 'https://github.com/mbbill/undotree',
    version = 'rel_6.1',
  },
  {
    src = 'https://github.com/petertriho/nvim-scrollbar',
    data = {
      config = function()
        require('scrollbar').setup()
      end
    },
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    data = {
      config = function()
        vim.defer_fn(function()
          require('nvim-treesitter.configs').setup({
            ensure_installed = {
              'lua',
              'python',
              'rust',
              'javascript',
              'html',
              'sql',
              'zig',
              'yaml',
              'vimdoc',
            },
            auto_install = true,
            sync_install = false,
            ignore_install = {},
            modules = {},
            highlight = { enable = true },
            indent = { enable = true },
          })
        end, 0)
      end
    },
  },
  {
    src = 'https://github.com/j-hui/fidget.nvim',
    data = {
      config = function()
        require('fidget').setup()
      end
    },
  },
  {
    src = 'https://github.com/L3MON4D3/LuaSnip',
  },
  {
    src = 'https://github.com/saadparwaiz1/cmp_luasnip',
  },
  {
    src = 'https://github.com/hrsh7th/cmp-nvim-lsp',
  },
  {
    src = 'https://github.com/hrsh7th/nvim-cmp',
    data = {
      config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup()

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            completeopt = 'menu,menuone,noinsert',
          },
          mapping = cmp.mapping.preset.insert {
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-Space>'] = cmp.mapping.complete {},
            ['<C-y>'] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
          },
        })
      end
    },
  },
})

-- run config functions for each plugin
-- if config order matters, make sure its sorted properly in the vim.pack.add list
for _, v in pairs(vim.pack.get()) do
  if v.spec.data and v.spec.data.config then
    v.spec.data.config()
  end
end

-- [[ configure lsp ]]
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')

  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')

  -- create command `:Format` local to the lsp buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local servers = {
  pyright = {},
  rust_analyzer = {},
  html = { filetypes = { 'html' } },
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
  zls = {},
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

for k, _ in pairs(servers) do
  require('lspconfig')[k].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = servers[k],
    filetypes = (servers[k] or {}).filetypes,
  })
end

-- vim: ts=2 sts=2 sw=2 et
