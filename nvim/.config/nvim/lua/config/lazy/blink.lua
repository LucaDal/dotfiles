-- lua/plugins/blink.lua
return {
  "saghen/blink.cmp",
  -- lo carichiamo presto così è disponibile per lspconfig
  event = "InsertEnter",
  version = "1.*",

  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "2.*",
      build = (function()
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      opts = {},
      config = function(_, opts)
        require("luasnip").setup(opts)
        require("luasnip.loaders.from_lua").lazy_load({
          paths = { vim.fn.stdpath("config") .. "/snippets" },
        })
      end,
    },
    "folke/lazydev.nvim",
  },

  --- @type blink.cmp.Config
  opts = {
    ------------------------------------------------------------------
    -- TASTI: TAB accetta, C-Space apre menu, C-n/C-p navigano
    ------------------------------------------------------------------
    keymap = {
      -- preset 'super-tab' = <Tab> accetta il completamento selezionato
      -- + include:
      --   <c-space> per aprire il menu / mostrare o nascondere la documentazione
      --   <c-n>/<c-p> per muoverti
      --   <tab>/<s-tab> per snippet
      preset = "super-tab",
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      documentation = { auto_show = false },
      ghost_text = { enabled = true },
      list = {
        selection = {
          -- Keep Tab available for snippet fields until an item is selected explicitly.
          preselect = function()
            return not require("blink.cmp").snippet_active({ direction = 1 })
          end,
          auto_insert = false,
        },
      },
    },

    sources = {
      default = { "lsp", "path", "snippets", "lazydev" },
      providers = {
        lazydev = {
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },

    snippets = { preset = "luasnip" },

    fuzzy = { implementation = "lua" },

    signature = { enabled = true },
  },
}
