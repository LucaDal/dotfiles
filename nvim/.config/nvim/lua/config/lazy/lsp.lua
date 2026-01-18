local root_files = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
}

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "L3MON4D3/LuaSnip",
        "j-hui/fidget.nvim",
        -- assicuriamoci che blink.cmp sia installato prima che qui venga richiesto
        "saghen/blink.cmp",
    },

    config = function()
        require("conform").setup({})

        -- opzioni consigliate per il completion
        vim.o.completeopt = "menu,menuone,noselect"
        vim.opt.shortmess:append("c")

        -- solo per sicurezza: non usiamo omnifunc, lasciamo blink gestire tutto
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                vim.bo[args.buf].omnifunc = ""
            end,
        })

        ------------------------------------------------------------------
        -- CAPABILITIES DA BLINK
        ------------------------------------------------------------------
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok_blink, blink = pcall(require, "blink.cmp")
        if ok_blink then
            capabilities = blink.get_lsp_capabilities(capabilities)
            -- se la funzione non accetta argomenti nella tua versione,
            -- puoi usare semplicemente: capabilities = blink.get_lsp_capabilities()
        end

        require("fidget").setup()
        require("mason").setup()

        local lspconfig = require("lspconfig")

        ------------------------------------------------------------------
        -- MASON + LSP
        ------------------------------------------------------------------
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "ts_ls",     -- TYPESCRIPT
                "clangd",    -- C / C++
                "pyright",
                --"rust_analyzer",
                -- "zls",    -- se ti serve zig
            },

            handlers = {
                -- handler di default
                function(server_name)
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                    })
                end,

                -- LUA LS -----------------------------------------------------
                ["lua_ls"] = function()
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                format = {
                                    enable = true,
                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "2",
                                    },
                                },
                                diagnostics = {
                                    globals = { "vim" },
                                },
                            },
                        },
                    })
                end,

                -- ZIG --------------------------------------------------------
                zls = function()
                    lspconfig.zls.setup({
                        capabilities = capabilities,
                        root_dir = lspconfig.util.root_pattern(
                            ".git",
                            "build.zig",
                            "zls.json"
                        ),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                end,

                --------------------------------------------------------------
                -- TYPESCRIPT / NODE ------------------------------------------
                --------------------------------------------------------------
                ["ts_ls"] = function()
                    lspconfig.ts_ls.setup({
                        capabilities = capabilities,
                        root_dir = lspconfig.util.root_pattern(unpack(root_files)),
                        settings = {
                            typescript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = "all",
                                    includeInlayVariableTypeHints = true,
                                    includeInlayFunctionParameterTypeHints = true,
                                    includeInlayPropertyDeclarationTypeHints = true,
                                },
                            },
                            javascript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = "all",
                                    includeInlayVariableTypeHints = true,
                                },
                            },
                        },
                    })
                end,

                --------------------------------------------------------------
                -- C / C++ (CLANGD) -------------------------------------------
                --------------------------------------------------------------
                ["clangd"] = function()
                    lspconfig.clangd.setup({
                        capabilities = capabilities,
                        cmd = {
                            "clangd",
                            "--background-index",
                            "--clang-tidy",
                            "--completion-style=detailed",
                            "--header-insertion=iwyu",
                        },
                        filetypes = {
                            "c",
                            "cpp",
                            "objc",
                            "objcpp",
                            "cuda",
                            "proto",
                        },
                        root_dir = lspconfig.util.root_pattern(
                            "compile_commands.json",
                            "compile_flags.txt",
                            "configure.ac",
                            ".git"
                        ),
                    })
                end,
            },
        })

        ------------------------------------------------------------------
        -- DIAGNOSTICA ---------------------------------------------------
        ------------------------------------------------------------------
        vim.diagnostic.config({
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
            },
        })
    end,
}
