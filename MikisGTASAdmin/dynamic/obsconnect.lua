local obsBusy = false
local activeOBSClient = nil
local obsShuttingDown = false

local __MGSAObsConnect__ = {}

local function safeClose(client)
    if not client then
        return
    end

    pcall(function()
        if client.sock_close then
            client:sock_close()
        end

        client.state = "CLOSED"
        client.is_closing = nil
    end)
end

local function patchOBSClient(client)
    client.sock_close = function(self)
        local sock = self.sock
        self.sock = nil

        if sock then
            pcall(function()
                sock:shutdown()
            end)

            pcall(function()
                sock:close()
            end)
        end
    end
end

local function receiveJSON(client)
    local ok, message, receiveErr = pcall(function()
        return client:receive()
    end)

    if not ok then
        return nil, tostring(message)
    end

    if not message then
        return nil, tostring(receiveErr or "Greska pri primanju WebSocket poruke.")
    end

    local decodeOK, data = pcall(decodeJson, message)
    if not decodeOK or type(data) ~= "table" then
        return nil, "Neispravna JSON poruka od OBS-a."
    end

    return data
end

local function sendJSON(client, data)
    local ok, result, sendErr = pcall(function()
        return client:send(encodeJson(data))
    end)

    if not ok or not result then
        return false, tostring(ok and sendErr or result)
    end

    return true
end
local function connectOBS()
    local client

    local createOK, createResult = pcall(function()
        client = MGSA_WEBSOCKET.client.sync{ timeout = 2 }
    end)

    if not createOK or not client then
        return nil, "Ne mogu napraviti OBS WebSocket klijent: " ..
            tostring(createResult)
    end

    -- Patchujemo upravo klijenta koji ćemo koristiti.
    patchOBSClient(client)

    local connectOK, connectResult, connectErr = pcall(function()
        return client:connect(
            "ws://" .. MGSA_OBS_HOSTNAME .. ":" .. tostring(MGSA_OBS_PORT)
        )
    end)

    if not connectOK or not connectResult then
        safeClose(client)
        return nil, "Neuspjesna konekcija sa OBS serverom: " ..
            tostring(connectOK and connectErr or connectResult)
    end

    local hello, helloErr = receiveJSON(client)
    if not hello or hello.op ~= 0 or not hello.d or not hello.d.rpcVersion then
        safeClose(client)
        return nil, helloErr or "OBS nije poslao ispravnu Hello poruku."
    end

    local identifyData = { rpcVersion = 1 }
    local auth = hello.d.authentication

    if auth then
        if not MGSA_OBS_PASSWORD or MGSA_OBS_PASSWORD == "" then
            safeClose(client)
            return nil, "OBS zahtijeva lozinku, ali lozinka nije postavljena."
        end

        local secretHash = MGSA_SHA.sha256(MGSA_OBS_PASSWORD .. auth.salt)
        local secretBase64 = MGSA_BASE64.encode(MGSA_SHA.hex_to_bin(secretHash))
        local responseHash = MGSA_SHA.sha256(secretBase64 .. auth.challenge)

        identifyData.authentication = MGSA_BASE64.encode(MGSA_SHA.hex_to_bin(responseHash))
    end

    local sent, sendErr = sendJSON(client, { op = 1, d = identifyData })
    if not sent then
        safeClose(client)
        return nil, "Greska pri slanju Identify paketa: " .. tostring(sendErr)
    end

    local identified, identifyErr = receiveJSON(client)
    if not identified or identified.op ~= 2 then
        safeClose(client)
        return nil, identifyErr or "OBS nije potvrdio konekciju. Provjeri postavke."
    end

    return client
end

local function obsRequest(client, requestType)
    local requestId = MGSA_UUID()

    local sent, sendErr = sendJSON(client, {
        op = 6,
        d = {
            requestType = requestType,
            requestId = requestId
        }
    })

    if not sent then
        return nil, "Greska pri slanju zahtjeva OBS-u: " .. tostring(sendErr)
    end

    for i = 1, 5 do
        local response, err = receiveJSON(client)
        if not response then
            return nil, err
        end

        if response.op == 7 and response.d
            and response.d.requestId == requestId then

            if not response.d.requestStatus
                or not response.d.requestStatus.result then
                local comment = response.d.requestStatus
                    and response.d.requestStatus.comment
                    or "Nepoznata OBS greska."
                return nil, comment
            end

            return response.d.responseData or {}
        end
    end

    return nil, "OBS nije vratio odgovor na zahtjev."
end

local function runOBSRequest(requestType, successCallback, startMessage)
    if obsShuttingDown then
        return
    end

    if obsBusy then
        sendWarningMessage("OBS zahtjev je vec u toku. Sacekaj da zavrsi.")
        return
    end

    obsBusy = true
    sendInfoMessage(startMessage)

    local client = nil

    local ok, result, requestErr = pcall(function()
        local connectedClient, connectErr = connectOBS()
        if not connectedClient then
            return nil, connectErr
        end

        client = connectedClient
        activeOBSClient = client

        if type(requestType) == "function" then
            return requestType(client)
        end

        return obsRequest(client, requestType)
    end)

    safeClose(client)
    obsBusy = false
    if activeOBSClient == client then
        activeOBSClient = nil
    end

    if not ok then
        sendErrorMessage("OBS/Lua greska: " .. tostring(result))
        return
    end

    if not result then
        sendErrorMessage("OBS Greska: " .. tostring(requestErr))
        return
    end

    local callbackOK, callbackErr = pcall(successCallback, result)
    if not callbackOK then
        sendErrorMessage("OBS prikaz rezultata nije uspio: " .. tostring(callbackErr))
    end
end

function __MGSAObsConnect__.toggle()
    if not MGSA_OBS then
        sendErrorMessage("Onemogucili ste SAMP-OBS konekciju!")
        return
    end
    runOBSRequest(
        function(client)
            -- Prvo provjeri trenutno stanje snimanja.
            local status, statusErr = obsRequest(client, "GetRecordStatus")

            if not status then
                return nil, statusErr
            end

            -- Eksplicitno pokreni ili zaustavi snimanje.
            local request

            if status.outputActive then
                request = "StopRecord"
            else
                request = "StartRecord"
            end

            local result, requestErr = obsRequest(client, request)

            if not result then
                return nil, requestErr
            end

            return {
                outputActive = not status.outputActive
            }
        end,
        function(result)
            if result.outputActive then
                sendSuccessMessage("Snimanje " .. COLOR_DARK_GREEN .. "upaljeno!")
            else
                sendSuccessMessage("Snimanje " .. COLOR_RED .. "ugaseno!")
            end

            sendWarningMessage(
                "Redovno provjeravaj OBS status da ne zaboravis snimati!"
            )
        end,
        "Povezujem se sa OBS serverom..."
    )
end

function __MGSAObsConnect__.toggleModule()
    MGSA_OBS = not MGSA_OBS
    if MGSA_OBS then
        sendSuccessMessage("Uspjesno ste omogucili SAMP-OBS modul.")
        return
    end
    sendWarningMessage("Onemogucili ste SAMP-OBS modul.")
end

function __MGSAObsConnect__.status()
    if not MGSA_OBS then
        sendErrorMessage("Onemogucili ste SAMP-OBS konekciju!")
        return
    end
    runOBSRequest(
        "GetRecordStatus",
        function(result)
            if result.outputActive then
                sendInfoMessage(
                    "Snimanje je " .. COLOR_DARK_GREEN .. "trenutno upaljeno!"
                )
            else
                sendInfoMessage(
                    "Snimanje trenutno " .. COLOR_RED .. "nije upaljeno!"
                )
            end
        end,
        "Provjeravam status snimanja..."
    )
end

function MGSA_SHUTDOWN_OBS()
    if obsShuttingDown then
        return
    end

    obsShuttingDown = true

    if activeOBSClient then
        safeClose(activeOBSClient)
        activeOBSClient = nil
    end

    obsBusy = false
end

function __MGSAObsConnect__.load()
    MGSA_LOADED_MODULE(
        {
            name = "SAMP-OBS Connect",
            desc = "Omogucava pokretanje snimanja u OBS preko\n odgovarajucih komandi."
        }
    )

    sendInfoMessage(
        "OBS WebSocket server: " ..
        COLOR_NEON_PURPLE ..
        MGSA_OBS_HOSTNAME ..
        ":" ..
        tostring(MGSA_OBS_PORT)
    )
end

return __MGSAObsConnect__
