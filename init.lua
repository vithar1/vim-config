vim.wo.number = true

vim.opt.tabstop = 4        -- ширина таба визуально
vim.opt.shiftwidth = 4     -- ширина при >> и <<
vim.opt.expandtab = true   -- заменять табы на пробелы
vim.opt.smartindent = true -- автоотступы

vim.opt.termguicolors = true

-- связывает системный буфер и буфер nvim
vim.opt.clipboard = "unnamedplus"

-- работа с терминалом
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- Перемещения по окнам в режиме терминала
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true })

-- комментирвоание
vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment line" })    -- Normal mode
vim.keymap.set("v", "<C-_>", "gc",  { remap = true, desc = "Toggle comment selection" }) -- Visual mode

vim.opt.spell = true
vim.opt.spelllang = "en,ru"

-- autosave
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.modifiable and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})

-- нужно для работы gopls языкового сервера
-- ensure ~/go/bin is in PATH for Neovim
local home = vim.fn.expand("~")
local gobin = home .. "/go/bin"
if not string.find(vim.env.PATH or "", gobin, 1, true) then
  vim.env.PATH = (vim.env.PATH and (vim.env.PATH .. ":") or "") .. gobin
end

-- нужно для работы менеджера плагинов
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- переключение между последними файлами
vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope buffers<CR>")

require("lazy").setup({
  	{
  	  "williamboman/mason.nvim",
  	  build = ":MasonUpdate",
  	  config = function()
  	    require("mason").setup()
  	  end
  	},
  	-- 🔧 LSP + автоподключение
  	{
  	  "neovim/nvim-lspconfig",
  	  config = function()
  	    require("lspconfig").lua_ls.setup({})
  	    require("lspconfig").pyright.setup({})
        -- настройка для гошки. Например чтобы переходить к определению функции     
        require('lspconfig').gopls.setup {
            on_attach = function(client, bufnr)
              local opts = { buffer = bufnr, noremap = true, silent = true }
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
              vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts) -- просмотр варнигов
              vim.keymap.set('n', '<leader>f', function()
                  vim.lsp.buf.format({ async = true })
              end, { desc = 'Format code' })
            end,
            settings = {
              gopls = {
                gofumpt = true,
                staticcheck = true,
                usePlaceholders = true,
                analyses = {
                  unusedparams = true,
                },
              },
            },
        }
  	  end
  	},
	-- подсветка синтаксиса
  	{
  	  "nvim-treesitter/nvim-treesitter",
  	  build = ":TSUpdate",
  	  config = function()
  	    require("nvim-treesitter.configs").setup({
  	      ensure_installed = { "lua", "python", "bash", "json", "html", "css", "go" },
  	      highlight = { enable = true },
  	    })
  	  end
  	},
	-- дерево проекта
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- для иконок файлов
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        update_focused_file = {
          enable = true,
        },

        -- Переопределяем маппинги для открытия файлов
        on_attach = function(bufnr)
            local api = require("nvim-tree.api")
            api.config.mappings.default_on_attach(bufnr)
        end,
      })

      -- Маппинг для открытия/закрытия дерева по <leader>e
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },
    -- комментирование кода
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  -- переключение между последними файлами
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("telescope").setup()
    end,
  }
})
