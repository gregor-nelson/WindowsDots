-- Plugin specifications for lazy.nvim
return {
  -- Icons (requires a Nerd Font)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- File tree explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
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
          custom = { ".git", "node_modules", ".cache" },
        },
        git = {
          enable = true,
          ignore = false,
        },
      })
    end,
    keys = {
      { "<C-e>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
  },

  -- Telescope: fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = { "Telescope" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.5,
            },
            width = 0.9,
            height = 0.8,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Custom One Dark theme matching init.lua colors
      local colors = {
        black  = "#1e222a",
        white  = "#abb2bf",
        gray2  = "#2e323a",
        gray3  = "#545862",
        gray4  = "#6d8dad",
        blue   = "#61afef",
        green  = "#7EC7A2",
        red    = "#e06c75",
        orange = "#caaa6a",
        yellow = "#EBCB8B",
        pink   = "#c678dd",
      }

      local onedark_custom = {
        normal = {
          a = { fg = colors.black, bg = colors.blue, gui = "bold" },
          b = { fg = colors.white, bg = colors.gray3 },
          c = { fg = colors.gray4, bg = colors.gray2 },
        },
        insert = {
          a = { fg = colors.black, bg = colors.green, gui = "bold" },
        },
        visual = {
          a = { fg = colors.black, bg = colors.pink, gui = "bold" },
        },
        replace = {
          a = { fg = colors.black, bg = colors.red, gui = "bold" },
        },
        command = {
          a = { fg = colors.black, bg = colors.orange, gui = "bold" },
        },
        inactive = {
          a = { fg = colors.gray4, bg = colors.gray2 },
          b = { fg = colors.gray4, bg = colors.gray2 },
          c = { fg = colors.gray4, bg = colors.gray2 },
        },
      }

      require("lualine").setup({
        options = {
          theme = onedark_custom,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()
      ts.install({ "css", "html", "javascript", "python" })

      -- Enable highlighting and indentation for these filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "css", "html", "javascript", "python" },
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Header: Neovim icon
      dashboard.section.header.val = {
        "",
        "  ",
        "",
      }

      -- Buttons (VS Code style)
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
        dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      -- Colors matching One Dark theme
      dashboard.section.header.opts.hl = "Function"
      dashboard.section.buttons.opts.hl = "Keyword"

      -- Layout
      dashboard.config.layout = {
        { type = "padding", val = 4 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
      }

      alpha.setup(dashboard.config)
    end,
  },
}
