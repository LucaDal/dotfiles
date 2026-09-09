local M = {
    model = "qwen3.5:latest",
    url = "http://127.0.0.1:11434",
    context = 16384
}

local starting = false

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "AI locale" })
end

-- All HTTP calls run asynchronously; no model loading blocks the editor.
local function request(path, body, timeout, callback)
    local args = { "curl", "--silent", "--show-error", "--fail-with-body",
        "--noproxy", "*", "--connect-timeout", "2", "--max-time", tostring(timeout), M.url .. path }
    if body then
        vim.list_extend(args, { "--header", "Content-Type: application/json", "--data-binary", "@-" })
    end
    vim.system(args, { text = true, stdin = body and vim.json.encode(body) or nil }, function(result)
        vim.schedule(function()
            local ok, data = pcall(vim.json.decode, result.stdout or "")
            if result.code ~= 0 then
                callback(nil, ok and data.error or vim.trim(result.stderr or "Richiesta fallita"))
            elseif not ok then
                callback(nil, "Risposta Ollama non valida")
            else
                callback(data)
            end
        end)
    end)
end

local function preload()
    local options = vim.empty_dict()
    options.num_ctx = M.context

    request("/api/generate", {
        model = M.model,
        stream = false,
        think = false,
        options = options,
    }, 120, function(_, err)
        starting = false

        if err then
            notify(
                "Caricamento fallito: " .. err .. ". Controlla :LocalAIStatus.",
                vim.log.levels.WARN
            )
        end
    end)
end

function M.start()
    if starting then
        return
    end
    if vim.fn.executable("curl") == 0 or vim.fn.executable("systemctl") == 0 then
        notify("L'avvio locale richiede curl e systemctl.", vim.log.levels.WARN)
        return
    end
    starting = true
    request("/api/version", nil, 2, function(data)
        if data then
            preload()
            return
        end
        vim.system({ "systemctl", "--user", "start", "ollama-nvim.service" }, { text = true }, function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    starting = false
                    notify("Ollama non avviato: " .. vim.trim(result.stderr), vim.log.levels.WARN)
                    return
                end
                local function wait_ready(attempt)
                    request("/api/version", nil, 2, function(ready, err)
                        if ready then
                            preload()
                        elseif attempt < 20 then
                            vim.defer_fn(function() wait_ready(attempt + 1) end, 250)
                        else
                            starting = false
                            notify("Ollama non risponde: " .. err, vim.log.levels.WARN)
                        end
                    end)
                end
                wait_ready(1)
            end)
        end)
    end)
end

function M.status()
    request("/api/ps", nil, 3, function(data, err)
        if err then
            notify("Ollama non raggiungibile: " .. err .. ". Avvia con :LocalAIStart.", vim.log.levels.WARN)
            return
        end
        for _, model in ipairs(data.models or {}) do
            if model.name == M.model or model.model == M.model then
                notify(string.format("%s — VRAM %.1f GiB; memoria totale %.1f GiB; contesto %s token",
                    M.model, (model.size_vram or 0) / 2 ^ 30, (model.size or 0) / 2 ^ 30,
                    model.context_length or M.context))
                return
            end
        end
        notify(starting and "Modello in caricamento…" or
            "Ollama attivo; il modello si caricherà alla prossima richiesta.")
    end)
end

function M.unload()
    if starting then
        notify("Caricamento in corso: riprova :LocalAIUnload al termine.")
        return
    end
    request("/api/generate", { model = M.model, keep_alive = 0, stream = false }, 30, function(_, err)
        notify(err and ("Scaricamento fallito: " .. err) or "Modello scaricato dalla memoria.",
            err and vim.log.levels.WARN or vim.log.levels.INFO)
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("LocalAIStart", M.start, { desc = "Avvia Ollama e precarica Qwen" })
    vim.api.nvim_create_user_command("LocalAIStatus", M.status, { desc = "Mostra modello e memoria utilizzata" })
    vim.api.nvim_create_user_command("LocalAIUnload", M.unload, { desc = "Libera la memoria del modello" })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("LocalAIStartup", { clear = true }),
        callback = function()
            if #vim.api.nvim_list_uis() > 0 then
                M.start()
            end
        end,
    })
end

return M
