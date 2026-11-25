
local __MGSACommandInput__ = {}

local active = false
local inputText = ""
local maxLength = 96
local font = nil
local render = false

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

local CONSOLE_INFO = {
    timer = nil,
    pos = {
        x = 0,
        y = 0
    },
    opacity = 0,
    delay = 0.0000001,
    max_y_offset = 50,
    max_opacity = 100
}

local PLACEHOLDER = "Unesite komandu ili pritisnite Enter za pomoc!"

function __MGSACommandInput__.isOpen()
    return active
end

function __MGSACommandInput__.open()
    if active then return false end

    inputText = ""
    active = true
    render = true

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

    if CONSOLE_INFO.timer ~= nil then
        MGSA_CHRONO.kill(CONSOLE_INFO.timer)
    end

    CONSOLE_INFO.opacity = 0
    CONSOLE_INFO.pos.y = CONSOLE_INFO.max_y_offset

    CONSOLE_INFO.timer = MGSA_CHRONO.task(
        CONSOLE_INFO.delay, function (id)
            if CONSOLE_INFO.opacity >= 100 or CONSOLE_INFO.pos.y <= 0 then
                CONSOLE_INFO.opacity = CONSOLE_INFO.max_opacity
                CONSOLE_INFO.pos.y = 0
                MGSA_CHRONO.kill(CONSOLE_INFO.timer)
                CONSOLE_INFO.timer = nil
                return
            end
            CONSOLE_INFO.opacity = CONSOLE_INFO.opacity + math.floor(CONSOLE_INFO.max_opacity / CONSOLE_INFO.max_y_offset)
            CONSOLE_INFO.pos.y = CONSOLE_INFO.pos.y - 1
        end, true
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

    if CONSOLE_INFO.timer ~= nil then
        MGSA_CHRONO.kill(CONSOLE_INFO.timer)
    end

    CONSOLE_INFO.timer = MGSA_CHRONO.task(
        CONSOLE_INFO.delay, function (id)
            if CONSOLE_INFO.opacity <= 0 then
                MGSA_CHRONO.kill(CONSOLE_INFO.timer)
                CONSOLE_INFO.timer = nil
                render = false
                return
            end
            CONSOLE_INFO.opacity = CONSOLE_INFO.opacity - math.floor(CONSOLE_INFO.max_opacity / CONSOLE_INFO.max_y_offset)
            CONSOLE_INFO.pos.y = CONSOLE_INFO.pos.y + 1
        end, true
    )

    return true
end

function __MGSACommandInput__.execute()
    if not active then return false end

    local command = inputText

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
        if (
            wasKeyPressed(MGSA_KEY_Z)
            and not MGSA_API.isSampChatOpened()
            and not MGSA_API.isSampDialogOnScreen()
            and not MGSADialog.isPendingDialog()
        ) then
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
    if not render then return end

    if not font then
        font = renderCreateFont("Arial", 10, 1)
    end

    local screenW, screenH = getScreenResolution()

    local x = math.floor((screenW - WIDTH) / 2) + CONSOLE_INFO.pos.x
    local y = math.floor((screenH - HEIGHT) / 2) + CONSOLE_INFO.pos.y

    renderDrawBoxWithBorder(
        x, y,
        WIDTH, HEIGHT,
        MGSARender.setColorOpacity(COLORS.background, CONSOLE_INFO.opacity - 25),
        2,
        MGSARender.setColorOpacity(MGSA_STICKMAN_COLOR, CONSOLE_INFO.opacity - 10)--COLORS.border
    )

    renderDrawBox(
        x + 2, y + 2,
        WIDTH - 4, 32,
        MGSARender.setColorOpacity(COLORS.header, CONSOLE_INFO.opacity)
    )

    renderFontDrawText(
        font,
        MGSA_PROJECT_NAME,
        x + 16, y + 11,
        MGSARender.setColorOpacity(COLORS.title, CONSOLE_INFO.opacity)
    )

    -- Opis.
    renderFontDrawText(
        font,
        "Unesite komandu:",
        x + 18, y + 47,
        MGSARender.setColorOpacity(COLORS.footer, CONSOLE_INFO.opacity)
    )

    renderDrawBoxWithBorder(
        x + 16, y + 68,
        WIDTH - 32, 36,
        MGSARender.setColorOpacity(COLORS.input, CONSOLE_INFO.opacity),
        1,
        MGSARender.setColorOpacity(COLORS.inputBorder, CONSOLE_INFO.opacity)
    )

    local displayText = inputText
    local textColor = MGSARender.setColorOpacity(COLORS.text, CONSOLE_INFO.opacity)

    if inputText == "" then
        displayText = PLACEHOLDER
        textColor = MGSARender.setColorOpacity(COLORS.placeholder, CONSOLE_INFO.opacity)
    end

    if math.floor(os.clock() * 2) % 2 == 0 then
        if inputText ~= "" then displayText = displayText .. "_" end
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
        MGSARender.setColorOpacity(COLORS.footer, CONSOLE_INFO.opacity)
    )

    renderFontDrawText(
        font,
        "ESC - odustani",
        x + WIDTH - 150, y + 119,
        MGSARender.setColorOpacity(COLORS.footer, CONSOLE_INFO.opacity)
    )
end

function __MGSACommandInput__.load()
    if not font then
        font = renderCreateFont("Arial", 10, 1)
    end
    MGSA_LOADED_MODULE(
        {
            name = "KomandKonzol",
            desc = "Interni modul koji implementira komandnu konzolu."
        }
    )
    return true
end

return __MGSACommandInput__
