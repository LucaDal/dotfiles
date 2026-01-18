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
      --   <c-space> per aprire menu / docs
      --   <c-n>/<c-p> per muoverti
      --   <tab>/<s-tab> per snippet
      preset = "super-tab",
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
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

