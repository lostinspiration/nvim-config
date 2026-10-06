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

vim.opt.spell = true
vim.opt.spelllang = "en_us"

vim.o.winborder = 'rounded'

vim.g.rust_recommended_style = false
vim.g.zig_recommended_style = false

-- [[ keymaps ]]

vim.keymap.set({ 'n', 'v' }, '<space>', '<Nop>', { silent = true })

-- dont touch unnamed register when pasting over visual selection
vim.keymap.set('v', 'P', '"_dP', { silent = true, noremap = true })

-- remap for dealing with wordwrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- move lines
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-Down>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
vim.keymap.set('n', '<A-Up>', ':m .-2<CR>==')
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('i', '<A-Down>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
vim.keymap.set('i', '<A-Up>', '<Esc>:m .-2<CR>==gi')
vim.keymap.set('v', '<A-j>', ':m \'>+1<CR>==gv')
vim.keymap.set('v', '<A-Down>', ':m \'>+1<CR>==gv')
vim.keymap.set('v', '<A-k>', ':m \'<-2<CR>==gv')
vim.keymap.set('v', '<A-Up>', ':m \'<-2<CR>==gv')

-- diagnostic keymaps
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({count = -1, float = true}) end, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({count = 1, float = true}) end, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.cmd.packadd('nvim.undotree')
vim.keymap.set('n', '<leader>u', '<Cmd>Undotree<CR>')

-- autocmd to support "build" properties on added packages
local built = {}
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("VimPackHooks", { clear = true }),
  callback = function(event)
    local kind = event.data.kind
    local spec = event.data.spec
    local path = event.data.path
    local build = spec.data and spec.data.build

    if (kind ~= "install" and kind ~= "update") or not build then
      return
    end

    -- skip if already built
    local key = path .. "::" .. build
    if built[key] then
      return
    end
    built[key] = true

    vim.notify(("Running build for %s: %s"):format(spec.name, build))

    if build:sub(1, 1) == ':' then
      vim.cmd.packadd(spec.name) -- plugin isn't loaded yet during install
      vim.cmd(build:sub(2))
      return
    end

    local obj = vim.system(
      { vim.o.shell, vim.o.shellcmdflag, build },
      { cwd = path, text = true }
    ):wait()

    if obj.code == 0 then
      vim.notify(("Built %s"):format(spec.name), vim.log.levels.INFO)
    else
      vim.notify(
        ("Build failed for %s (exit %d)\n%s"):format(spec.name, obj.code, obj.stderr or ""),
        vim.log.levels.ERROR
      )
      -- allow retry on failure
      built[key] = nil
    end
  end,
})

-- [[ packages ]]
local specs = {
  {
    src = 'https://github.com/nvim-lua/plenary.nvim',
    version = 'v0.1.4',
  },
  {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    version = 'master',
    data = {
      build = 'make',
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
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
        vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>ts', function()
          builtin.treesitter({ symbols = { 'function', 'type' } })
        end, { desc = '[T]ree [S]itter' })
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
        require('mason').setup({
          registries = {
            'github:mason-org/mason-registry',
            'github:Crashdummyy/mason-registry', -- provides `roslyn` (and `rzls`)
          },
        })
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
    src = 'https://github.com/petertriho/nvim-scrollbar',
    data = {
      config = function()
        require('scrollbar').setup()
      end
    },
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
    data = {
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter').install({
          'lua', 'python', 'rust', 'javascript', 'html', 'sql',
          'zig', 'yaml', 'vimdoc', 'c_sharp',
        })
        vim.api.nvim_create_autocmd('FileType', {
          callback = function(args)
            if pcall(vim.treesitter.start, args.buf) then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end,
        })
      end
    },
  },
  {
    src = 'https://github.com/j-hui/fidget.nvim',
    data = {
      config = function()
        require('fidget').setup({})
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
            autocomplete = false,
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
  {
    src = 'https://github.com/Wansmer/symbol-usage.nvim',
    data = {
      config = function()
        require('symbol-usage').setup({})
      end
    },
  },
  -- {
  --   src = 'https://github.com/zongben/dbout.nvim',
  --   data = {
  --     config = function()
  --       require('dbout').setup()
  --     end,
  --     build = "npm install",
  --   },
  -- },
  {
    src = 'https://github.com/seblyng/roslyn.nvim',
    data = {
      config = function()
        require('roslyn').setup({
          -- all optional
          broad_search = false, -- search parent dirs for .sln when true
          lock_target = false, -- keep the chosen sln/csproj across restarts
          silent = false,
        })
      end
    },
  },
  {
    src = 'https://github.com/mfussenegger/nvim-dap',
    data = {
      config = function()
        local dap = require("dap")

        dap.adapters.coreclr = {
          type = "executable",
          -- mason.nvim normally puts its bin dir on PATH; if not, use the absolute path:
          -- vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
          command = "netcoredbg",
          args = { "--interpreter=vscode" },
        }

        -- Find the built dll by asking for the project folder, then globbing bin/Debug
        local function pick_dll()
          local dir = vim.fn.input("Project dir: ", vim.fn.getcwd() .. "/", "dir")
          local dlls = vim.fn.glob(dir .. "/bin/Debug/net*/*.dll", false, true)
          -- prefer the dll named after the folder
          local name = vim.fn.fnamemodify(dir:gsub("/$", ""), ":t")
          for _, d in ipairs(dlls) do
            if vim.fn.fnamemodify(d, ":t:r") == name then return d end
          end
          return vim.fn.input("Path to dll: ", dir .. "/bin/Debug/net*/", "file")
        end

        dap.configurations.cs = {
          {
            type = "coreclr",
            name = "Launch (build first)",
            request = "launch",
            program = pick_dll,
            cwd = function() return vim.fn.input("Working dir: ", vim.fn.getcwd() .. "/", "dir") end,
            env = { ASPNETCORE_ENVIRONMENT = "Development" },
          },
        }

        vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP continue/start" })
        vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP step over" })
        vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP step into" })
        vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP step out" })
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "DAP REPL" })
        vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "DAP terminate" })
      end
    },
  },
}

-- run config functions for each plugin
-- if config order matters, make sure its sorted properly in the specslist
vim.pack.add(specs)
for _, v in pairs(specs) do
  local config = v.data and v.data.config
  if config then
    local ok, err = pcall(config)
    if not ok then
      vim.notify(("Config failed for %s: %s"):format(v.name, err), vim.log.levels.ERROR)
    end
  end
end

-- [[ configure lsp ]]
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local nmap = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')

    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    vim.api.nvim_buf_create_user_command(bufnr, 'AutoCompleteOn', function()
      require('cmp').setup({
        completion = {
          autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged }
        }
      })
    end, { desc = 'Auto Completion On' })

    vim.api.nvim_buf_create_user_command(bufnr, 'AutoCompleteOff', function()
      require('cmp').setup({
        completion = {
          autocomplete = false
        }
      })
    end, { desc = 'Auto Completion Off' })
  end,
})

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(), -- drop if you go native completion
})

vim.lsp.config('html', { filetypes = { 'html' } })
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ 'pyright', 'rust_analyzer', 'html', 'lua_ls', 'zls' })

-- vim: ts=2 sts=2 sw=2 et
