local __MGSAAltChat__ = {}

local MAX_LINES = 10
local MESSAGE_HISTORY = {}
local MGSA_ALT_INTERVAL = 10
local loaded = false

function __MGSAAltChat__.load()
    if MGSA_FONTS_FAILED then
        return
    end
    MGSA_LOADED_MODULE({
        name = "Alternativni Chat",
        desc = "Modul koji ugradjuje alternativni chat."
    })
    loaded = true
    return
end


local function send____(format)
    if not loaded then return end
    local newformat = {}
    table.insert(newformat, {
        text = os.date("[%H:%M:%S] "),
        color = SVIJETLO_SIVA
    })
    for _, part in ipairs(format) do
        table.insert(newformat, part)
    end

    if #MESSAGE_HISTORY >= MAX_LINES then
        table.remove(MESSAGE_HISTORY, 1)
    end

    table.insert(MESSAGE_HISTORY, newformat)
end

function __MGSAAltChat__.send(format)
    send____(format)
end

MGSA_ALT_CHAT_CLEAR = 0

function __MGSAAltChat__.loop()
    if not loaded then return end
    if not MGSA_ALT_CHAT then return end
    local font = MGSA_FONT_SMALL
    local h = renderGetFontDrawHeight(font)
    local x = 45
    local y = 600
    for i,format in ipairs(MESSAGE_HISTORY) do
        y = y + h + 3
        MGSARender.renderComplexLabel(font, x,y,format,MGSA_RENDER_ALIGNMENT_LEFT)
    end
    return
end

function __MGSAAltChat__.toggle()
    MGSA_ALT_CHAT = not MGSA_ALT_CHAT
    if MGSA_ALT_CHAT then
        sendSuccessMessage("Uspjesno se ukljucili alt chat.")
        return
    end
    sendWarningMessage("Uspjesno ste ugasili alt chat!")
end

local l = os.clock()

function __MGSAAltChat__.update()
    local c = os.clock()

    if c - l >= MGSA_ALT_INTERVAL then
        if #MESSAGE_HISTORY > 0 then
            table.remove(MESSAGE_HISTORY, 1)
        end
        l = c
    end
end



return __MGSAAltChat__