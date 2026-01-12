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
          cursorline = true,
        },
        renderer = {
          group_empty = true,
          root_folder_label = ":t",
          indent_width = 2,
          indent_markers = {
            enable = false,
          },
          icons = {
            padding = " ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
            },
            glyphs = {
              default = "󰈙",
              symlink = "",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "󰉋",
                open = "󰝰",
                empty = "󰉖",
                empty_open = "󰷏",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "󰄱",
                staged = "󰱒",
                unmerged = "",
                renamed = "󰁕",
                untracked = "",
                deleted = "󰛲",
                ignored = "󰈅",
              },
            },
          },
          highlight_git = true,
          highlight_opened_files = "name",
          highlight_modified = "name",
        },
        modified = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = false,
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
    branch = "master",
    cmd = { "Telescope" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = vim.fn.has("win32") == 1
          and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
          or "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          prompt_title = " Search ",
          results_title = " Results ",
          preview_title = " Preview ",
          sorting_strategy = "ascending",
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
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
      -- Load unified theme
      local config_path = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":h")
      local theme = dofile(config_path .. "/theme.lua")

      require("lualine").setup({
        options = {
          theme = theme.lualine_theme,
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
      local ts_install = require("nvim-treesitter.install")

      -- Platform-specific setup
      if vim.fn.has("win32") == 1 then
        -- Windows: zigcc wrapper calls "zig cc" for self-contained binaries
        ts_install.compilers = { "zigcc" }
      else
        -- Linux/Termux: use gcc/clang
        ts_install.compilers = { "gcc", "clang", "zig" }
      end

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

  -- Color previews (show hex colors inline)
  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        "*",  -- all filetypes
      }, {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",  -- or "foreground" or "virtualtext"
      })
    end,
  },

  -- Bufferline (visual tabs for buffers)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local config_path = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":h")
      local theme = dofile(config_path .. "/theme.lua")
      local c = theme.colors

      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "thin",
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "NvimTree", text = "Files", highlight = "Directory", separator = true },
          },
        },
        highlights = {
          fill = { bg = c.black },
          background = { fg = c.gray4, bg = c.black },
          buffer_visible = { fg = c.gray4, bg = c.black },
          buffer_selected = { fg = c.white, bg = c.gray2, bold = true },
          separator = { fg = c.gray2, bg = c.black },
          separator_visible = { fg = c.gray2, bg = c.black },
          separator_selected = { fg = c.gray2, bg = c.gray2 },
          indicator_selected = { fg = c.blue, bg = c.gray2 },
          modified = { fg = c.orange, bg = c.black },
          modified_visible = { fg = c.orange, bg = c.black },
          modified_selected = { fg = c.orange, bg = c.gray2 },
          tab = { fg = c.gray4, bg = c.black },
          tab_selected = { fg = c.white, bg = c.gray2, bold = true },
          tab_close = { fg = c.red, bg = c.black },
        },
      })
    end,
    keys = {
      { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<leader>x", "<cmd>bdelete<cr>", desc = "Close buffer" },
    },
  },

  -- Indent guides (vertical lines for indentation)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local config_path = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":h")
      local theme = dofile(config_path .. "/theme.lua")
      local c = theme.colors

      -- Set highlight groups for indent guides
      vim.api.nvim_set_hl(0, "IblIndent", { fg = c.gray2 })
      vim.api.nvim_set_hl(0, "IblScope", { fg = c.blue })

      require("ibl").setup({
        indent = {
          char = "│",
          highlight = "IblIndent",
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = "IblScope",
        },
        exclude = {
          filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy" },
        },
      })
    end,
  },
}
