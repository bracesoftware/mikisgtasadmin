
local __MGSACommandInput__ = {}

local active = false
local inputText = ""
local maxLength = 96
local font = nil

local WIDTH = 500
local HEIGHT = 145

local COLORS = {
    background = 0xF014141C,
    header = 0xFF211B30,
    border = 0xFF8A2BE2,
    title = 0xFFB58AFF,
    text = 0xFFFFFFFF,
    placeholder = 0xFF888899,
    input = 0xFF20202B,
    inputBorder = 0xFF8064C8,
    footer = 0xFFAAAAAA
}

local PLACEHOLDER =
    "Unesite komandu ili pritisnite Enter za pomoc"



function __MGSACommandInput__.isOpen()
    return active
end

function __MGSACommandInput__.open()
    if active then return false end

    inputText = ""
    active = true

    MGSA_API.setPlayerControllable(false)
    MGSAAltChat.send(
        {
            {
                text = "[KONZOLA] ",
                color = TIRKIZNA
            },
            {
                text = "Konzola uspjesno otvorena!",
                color = SIVA
            }
        }
    )

    return true
end

function __MGSACommandInput__.close()
    if not active then return false end

    active = false
    inputText = ""

    MGSA_CHRONO.task(0.2, function ()
        MGSA_API.setPlayerControllable(true)
    end, false)
    MGSAAltChat.send(
        {
            {
                text = "[KONZOLA] ",
                color = TIRKIZNA
            },
            {
                text = "Konzola zatvorena!",
                color = SIVA
            }
        }
    )

    return true
end

function __MGSACommandInput__.execute()
    if not active then return false end

    local command = inputText

    if command == "" then
        wait(100)
    end

    __MGSACommandInput__.close()

    if type(MGSA_KOMANDE) ~= "function" then
        print("[MGSA INPUT] MGSA_KOMANDE nije dostupna!")
        return false
    end

    local s, err = pcall(MGSA_KOMANDE, command)

    if not s then
        print("[MGSA INPUT] Greska: " .. tostring(err))
        return false
    end

    return true
end

function __MGSACommandInput__.loop()
    if not active then
        if wasKeyPressed(MGSA_KEY_Z) and not MGSA_API.isSampChatOpened() and not MGSA_API.isSampDialogOnScreen() then
            __MGSACommandInput__.open()
        end
        return
    end

    if wasKeyPressed(MGSA_KEY_ENTER) then
        __MGSACommandInput__.execute()
        return
    end

    if wasKeyPressed(MGSA_KEY_ESC) then
        __MGSACommandInput__.close()
        return
    end

    if wasKeyPressed(MGSA_KEY_BACKSPACE) then
        inputText = inputText:sub(1, -2)
    end

    for i = 0, 9 do
        local key = 0x30 + i
        if wasKeyPressed(key) and #inputText < maxLength then
            inputText = inputText .. tostring(i)
        end
    end

    for i = 0, 25 do
        local key = 0x41 + i

        if wasKeyPressed(key) and #inputText < maxLength then
            local shift =
                isKeyDown(0x10) or
                isKeyDown(0xA0) or
                isKeyDown(0xA1)

            local char = string.char(65 + i)

            if not shift then
                char = char:lower()
            end

            inputText = inputText .. char
        end
    end

    if wasKeyPressed(MGSA_KEY_SPACE) and #inputText < maxLength then
        inputText = inputText .. " "
    end
end

function __MGSACommandInput__.render()
    if not active then return end

    if not font then
        font = renderCreateFont("Arial", 10, 1)
    end

    local screenW, screenH = getScreenResolution()

    local x = math.floor((screenW - WIDTH) / 2)
    local y = math.floor((screenH - HEIGHT) / 2)

    renderDrawBoxWithBorder(
        x, y,
        WIDTH, HEIGHT,
        COLORS.background,
        2,
        MGSA_STICKMAN_COLOR--COLORS.border
    )

    renderDrawBox(
        x + 2, y + 2,
        WIDTH - 4, 32,
        COLORS.header
    )

    renderFontDrawText(
        font,
        MGSA_PROJECT_NAME,
        x + 16, y + 11,
        COLORS.title
    )

    -- Opis.
    renderFontDrawText(
        font,
        "Unesite komandu:",
        x + 18, y + 47,
        COLORS.footer
    )

    renderDrawBoxWithBorder(
        x + 16, y + 68,
        WIDTH - 32, 36,
        COLORS.input,
        1,
        COLORS.inputBorder
    )

    local displayText = inputText
    local textColor = COLORS.text

    if inputText == "" then
        displayText = PLACEHOLDER
        textColor = COLORS.placeholder
    end

    if math.floor(os.clock() * 2) % 2 == 0 then
        displayText = displayText .. "_"
    end

    renderFontDrawText(
        font,
        displayText,
        x + 27, y + 80,
        textColor
    )

    renderFontDrawText(
        font,
        "ENTER - izvrsi",
        x + 18, y + 119,
        COLORS.footer
    )

    renderFontDrawText(
        font,
        "ESC - odustani",
        x + WIDTH - 150, y + 119,
        COLORS.footer
    )
end

function __MGSACommandInput__.load()
    if not font then
        font = renderCreateFont("Arial", 10, 1)
    end

    return true
end

return __MGSACommandInput__
