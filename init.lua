-- Neovim Config - Zig, C#, TypeScript
-- ====================================

-- Leader key
vim.g.mapleader = " "

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Settings
vim.g.ctrl_move_lines = 10  -- Default jump amount for Ctrl+Up/Down

-- Custom command to change jump amount
vim.api.nvim_create_user_command("CtrlMove", function(opts)
  local num = tonumber(opts.args)
  if num and num > 0 then
    vim.g.ctrl_move_lines = num
    print("Ctrl move set to " .. num .. " lines")
  else
    print("Current: " .. vim.g.ctrl_move_lines .. " lines. Usage: :CtrlMove <number>")
  end
end, { nargs = "?" })

-- Keymaps
vim.keymap.set({"n", "i", "v"}, "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })
vim.keymap.set({"n", "v"}, "<C-;>", ":", { desc = "Command mode" })
vim.keymap.set("i", "<C-;>", "<Esc>:", { desc = "Command mode" })
vim.keymap.set("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set({"n", "i", "v"}, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<C-r><C-r>", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set({"n", "v"}, "<C-Up>", function() vim.cmd("normal! " .. vim.g.ctrl_move_lines .. "k") end, { desc = "Move up X lines" })
vim.keymap.set({"n", "v"}, "<C-Down>", function() vim.cmd("normal! " .. vim.g.ctrl_move_lines .. "j") end, { desc = "Move down X lines" })

-- Jump to next/previous statement (const, fn, struct fields)
local statement_pattern = "^\\s*\\(pub\\s\\+\\)\\?\\(const\\|fn\\|var\\)\\s\\|^\\s*\\w\\+:"
vim.keymap.set("n", "<A-Down>", function()
  vim.fn.search(statement_pattern, "W")
end, { desc = "Next statement" })
vim.keymap.set("n", "<A-Up>", function()
  vim.fn.search(statement_pattern, "bW")
end, { desc = "Previous statement" })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Colorscheme (ThePrimeagen's exact setup)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        disable_background = true,
        styles = {
          italic = false,
        },
      })

      vim.cmd.colorscheme("rose-pine-moon")

      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<C-f>", builtin.live_grep, { desc = "Search in files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    end,
  },

  -- Harpoon (quick file switching)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

      vim.keymap.set("n", "<A-1>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<A-2>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<A-3>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<A-4>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Shared on_attach function for all LSPs
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
      end

      -- Zig
      lspconfig.zls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- C# (OmniSharp)
      lspconfig.omnisharp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = { "omnisharp" },
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
      })

      -- TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })
    end,
  },
})
