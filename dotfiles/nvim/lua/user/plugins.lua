return {
  -- ═══════════════════════════════════════════════════════════════════════
  -- Theme
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          treesitter = true,
          native_lsp = { enabled = true },
          lsp_trouble = false,
          cmp = true,
          gitsigns = true,
          telescope = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Core utilities
  -- ═══════════════════════════════════════════════════════════════════════
  { "tpope/vim-surround" },
  { "tpope/vim-commentary" },
  { "ap/vim-css-color" },

  -- ═══════════════════════════════════════════════════════════════════════
  -- File tree
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "preservim/nerdtree",
    config = function()
      vim.g.NERDTreeBookmarksFile = vim.fn.stdpath("data") .. "/NERDTreeBookmarks"
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Writing tools
  -- ═══════════════════════════════════════════════════════════════════════
  { "junegunn/goyo.vim" },
  { "vimwiki/vimwiki",
    init = function()
      vim.g.vimwiki_ext2syntax = {
        [".Rmd"] = "markdown", [".rmd"] = "markdown",
        [".md"] = "markdown", [".markdown"] = "markdown",
        [".mdown"] = "markdown",
      }
      vim.g.vimwiki_list = {{
        path = "~/.local/share/nvim/vimwiki",
        syntax = "markdown",
        ext = ".md",
      }}
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Git
  -- ═══════════════════════════════════════════════════════════════════════
  { "jreybert/vimagit" },
  { "lewis6991/gitsigns.nvim", config = true },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Status line
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({ options = { theme = "material" } })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- LSP
  -- ═══════════════════════════════════════════════════════════════════════
  { "neovim/nvim-lspconfig" },
  { "nvim-lua/plenary.nvim" },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Lean 4
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "Julian/lean.nvim",
    init = function()
      vim.g.lean_config = {
        mappings = true,
        infoview = { autoopen = true },
      }
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- LaTeX — vimtex
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_quickfix_mode = 1
      vim.g.tex_conceal = "abdmg"
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Telescope — fuzzy finder
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Which-key
  -- ═══════════════════════════════════════════════════════════════════════
  { "folke/which-key.nvim", config = true },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Treesitter
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      ts.setup({
        ensure_installed = {
          "latex", "markdown", "markdown_inline",
          "bash", "lua", "vim",
          "python", "json", "yaml", "toml",
          "gitcommit", "git_rebase", "diff",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════════
  -- Autocompletion — nvim-cmp
  -- ═══════════════════════════════════════════════════════════════════════
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

}
