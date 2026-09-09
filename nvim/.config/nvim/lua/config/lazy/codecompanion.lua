local ai = require("config.local_ai")

return {
    "olimorris/codecompanion.nvim",
    version = "v19.23.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    init = ai.setup,
    keys = {
        { "<leader>oc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI: apri/chiudi chat" },
        { "<leader>oc", ":CodeCompanionChat<cr>",            mode = "x",                    desc = "AI: chat sulla selezione" },
        { "<leader>oe", ":CodeCompanion ",                   mode = { "n", "x" },           desc = "AI: chiedi una modifica" },
        { "<leader>oi", ai.status,                           desc = "AI: stato e memoria" },
        { "<leader>os", ai.start,                            desc = "AI: avvia e precarica" },
        { "<leader>ou", ai.unload,                           desc = "AI: libera memoria" },
    },
    opts = {
        adapters = {
            http = {
                ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        env = {
                            url = ai.url,
                        },

                        schema = {
                            model = {
                                default = ai.model,
                                choices = {
                                    [ai.model] = {
                                        opts = {
                                            can_reason = true,
                                            can_use_tools = true,
                                            has_vision = false,
                                        },
                                    },
                                },
                            },

                            think = {
                                default = false,
                            },

                            num_ctx = {
                                default = ai.context,
                            },
                        },

                    })
                end,
            },
        },
        interactions = {
            chat = {
                adapter = "ollama",

                tools = {
                    groups = {
                        project = {
                            description = "Esplora e legge il progetto corrente",

                            system_prompt = function(_, ctx)
                                return string.format([[
Sei un assistente di programmazione integrato in Neovim.

La directory root del workspace è ESATTAMENTE:
%s

Regole:
- considera esclusivamente file dentro questa directory;
- non inventare mai percorsi di file;
- non inventare mai risultati degli strumenti;
- per informazioni sul progetto, usa gli strumenti prima di rispondere;
- usa solo percorsi restituiti dagli strumenti;
- se un file non viene trovato, dichiaralo esplicitamente;
- non modificare né cancellare file;
- rispondi in italiano in modo conciso.
]], ctx.cwd)
                            end,


                            tools = {
                                "file_search",
                                "grep_search",
                                "read_file",
                                "insert_edit_into_file",
                                "get_changed_files",
                            },

                            opts = {
                                collapse_tools = true,
                                ignore_system_prompt = true,
                                ignore_tool_system_prompt = true,
                            },
                        },
                    },

                    opts = {
                        default_tools = {
                            "project",
                        },
                    },
                },


                keymaps = {
                    send = {
                        modes = {
                            n = "<CR>",
                            i = "<C-CR>",
                        },
                    },
                },

            },

            inline = {
                adapter = "ollama",
            },

            cmd = {
                adapter = "ollama",
            },

            background = {
                adapter = "ollama",
                chat = {
                    opts = {
                        enabled = false,
                    },
                },
            },
        },
        opts = { language = "Italian" },
    },
}
