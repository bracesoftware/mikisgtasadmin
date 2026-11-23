-- Osnovne boje (ARGB format - 100% neprozirno)
 BIJELA        = 0xFFFFFFFF
 CRNA          = 0xFF000000
 CRVENA        = 0xFFFF0000
 ZELENA        = 0xFF00FF00
 PLAVA         = 0xFF0000FF
 ZUTA          = 0xFFFFFF00
 CIJAN         = 0xFF00FFFF
 MAGENTA       = 0xFFFF00FF
 YELLOW = ZUTA
 GREEN = ZELENA

BLUE_LOL = 0xff2596be
BLUE_AS_SEA = 0xff08679f
CLOUDY_BLUE_OLD = 0xffd4fffe
CLOUDY_BLUE = 0xff93f5f0
-- Nijanse sive
 SVIJETLO_SIVA = 0xFFD3D3D3
 SIVA          = 0xFF808080
 TAMNO_SIVA    = 0xFFA9A9A9
 UGLJEN_SIVA   = 0xFF36454F
 BEAUTIFUL_PURPLE = 0xff9F2B68
 EGGPLANT_PURPLE = 0xff483248
 NICE_PURPLE = 0xff4C02F2

-- Nijanse crvene i narandžaste
 TAMNO_CRVENA  = 0xFF8B0000
 GRIMIZNA      = 0xFFDC143C
 KORALJNA      = 0xFFFF7F50
 NARANDZASTA   = 0xFFFFA500
 VENA = 0xff260A04
 ZLATNA        = 0xFFFFD700
 ORANGE = NARANDZASTA
 GOLD = ZLATNA

-- Nijanse zelene
 LIMETA        = 0xFF32CD32
 TAMNO_ZELENA  = 0xFF006400
 MASLINASTA    = 0xFF808000
 TIRKIZNA      = 0xFF40E0D0
 DARK_GREEN = TAMNO_ZELENA
-- Nijanse plave i ljubičaste
 NEBESKO_PLAVA = 0xFF87CEEB
 KRALJEVSKA    = 0xFF4169E1
 TAMNO_PLAVA   = 0xFF00008B
 LJUBICASTA    = 0xFF800080
 INDIGO        = 0xFF4B0082
 ROZA          = 0xFFFFC0CB

-- Zemljani tonovi
 SMEDJA        = 0xFFA52A2A
 COKOLADNA     = 0xFFD2691E
 BEZ           = 0xFFF5F5DC

-- Posebne (Prozirnost)
 POTPUNO_PROZIRNA = 0x00000000
 POLUPROZIRNA_CRNA = 0x80000000

 DUH_PLAVA = 0xFFD8EEF0
 LIGHT_GRAY = 0xffbabfbf

MGSA_FONT = renderCreateFont("Arial", 10, 5)
MGSA_FONT_BOLD = renderCreateFont("Arial", 10, 13)
MGSA_FONT_SMALL = renderCreateFont("Arial", 8, 5)

MGSA_FONTS_FAILED = (not MGSA_FONT) or (not MGSA_FONT_BOLD) or (not MGSA_FONT_SMALL)

local __MGSARender__ = {
    ICONS = {
        HOUSE = {
            color = 0xff177551,
            bitmap = {
                tonumber("00011000", 2),
                tonumber("00111100", 2),
                tonumber("01111110", 2),
                tonumber("11111111", 2),
                tonumber("10011001", 2),
                tonumber("10011001", 2),
                tonumber("10011111", 2),
                tonumber("11111111", 2)
            }
        }
    }
}

function __MGSARender__.drawBitmap(bitmap, x, y, color, boxSize)
    boxSize = boxSize or 1

    for row = 1, #bitmap do
        local bits = bitmap[row]
        local col = 0

        while col < 8 do
            if MGSA_BIT.band(bits, MGSA_BIT.lshift(1, 7 - col)) == 0 then
                col = col + 1
            else
                local start = col

                repeat
                    col = col + 1
                until col >= 8 or MGSA_BIT.band(bits, MGSA_BIT.lshift(1, 7 - col)) == 0

                renderDrawBox(
                    x + start * boxSize,
                    y + (row - 1) * boxSize,
                    (col - start) * boxSize,
                    boxSize,
                    color
                )
            end
        end
    end
end

function __MGSARender__.drawBitmapCentered(bm, x,y,col,size)
    x = x - 4 * size
    y = y - (#bm / 2) * size
    __MGSARender__.drawBitmap(bm,x,y,col,size)
end

function __MGSARender__.drawCircleWithThickness(x, y, radius, color, segments, thickness)
    segments = segments or 48

    for i = 0, segments - 1 do
        local a1 = (i / segments) * math.pi * 2
        local a2 = ((i + 1) / segments) * math.pi * 2

        local x1 = x + math.cos(a1) * radius
        local y1 = y + math.sin(a1) * radius

        local x2 = x + math.cos(a2) * radius
        local y2 = y + math.sin(a2) * radius

        renderDrawLine(x1, y1, x2, y2, thickness, color)
    end
end

function __MGSARender__.drawCircle(x,y,r,c,s)
    __MGSARender__.drawCircleWithThickness(x,y,r,c,s,1.5)
end
-----------------------

MGSA_RENDER_ALIGNMENT_LEFT = 0
MGSA_RENDER_ALIGNMENT_CENTER = 1

function __MGSARender__.renderCenteredText(font, text, x, y, color)
    local width = renderGetFontDrawTextLength(font, text)
    renderFontDrawText(
        font,
        text,
        x - width / 2,
        y,
        color
    )
end

function __MGSARender__.renderBar(font, value, maxValue, cx, cy, width, height, fillColor, backgroundColor, textColor,extraText)
    local ratio = math.min(math.max(value / maxValue, 0), 1)
    local startX = cx - (width / 2) 
    local startY = cy - (height / 2)

    renderDrawBox(startX, startY, width, height, backgroundColor)

    local fillWidth = width * ratio
    if fillWidth > 0 then
        renderDrawBox(startX, startY, fillWidth, height, fillColor)
    end

    local percentText = string.format("%.0f"..extraText, ratio * 100)
    local fontHeight = renderGetFontDrawHeight(font)
    __MGSARender__.renderCenteredText(font, percentText, cx, cy - (fontHeight / 2), textColor)
end

local MGSA_BAR_HEIGHT_MULTIPLIER = 0.5
local MGSA_BAR_WIDTH_MULTIPLIER = 6

function __MGSARender__.renderHealthBar(font, hp, x, y)
    local h = renderGetFontDrawHeight(font)

    __MGSARender__.renderBar(
        font, hp, 100.0,
        x, y + (h / 2), h * MGSA_BAR_WIDTH_MULTIPLIER, h * MGSA_BAR_HEIGHT_MULTIPLIER,
        TAMNO_CRVENA, VENA, BIJELA,""
    )
end

function __MGSARender__.renderArmorBar(font, armor, x, y)
    local h = renderGetFontDrawHeight(font)

    __MGSARender__.renderBar(
        font, armor, 100.0,
        x, y + (h / 2), h * MGSA_BAR_WIDTH_MULTIPLIER, h * MGSA_BAR_HEIGHT_MULTIPLIER,
        BIJELA, SIVA, SVIJETLO_SIVA,""
    )
end

function __MGSARender__.renderVehicleHealthBar(font, hp, x, y)
    local h = renderGetFontDrawHeight(font)

    __MGSARender__.renderBar(
        font, hp, 1000.0,
        x, y + (h / 2), h * MGSA_BAR_WIDTH_MULTIPLIER, h * MGSA_BAR_HEIGHT_MULTIPLIER,
        BEAUTIFUL_PURPLE, EGGPLANT_PURPLE, BIJELA,""
    )
end

function MGSA_GET_PING_COLOR(ping)
    if ping < 40 then return CLOUDY_BLUE
    elseif ping < 70 then return GREEN
    elseif ping < 140 then return YELLOW
    elseif ping < 200 then return ORANGE
    else return CRVENA
    end
end

-------------------------------------

function __MGSARender__.renderComplexLabel(font, x, y, parts, alignment)
    local SUS_THING = renderGetFontDrawTextLength(font, MGSA_TAB..MGSA_TAB..MGSA_TAB..MGSA_TAB .. MGSA_TAB .. MGSA_TAB..MGSA_TAB..MGSA_TAB)
    local totalWidth = 0

    for _, part in ipairs(parts) do
        if part.text:match("^#[hva]bar#[%d%.]+#$") then
            totalWidth = totalWidth + SUS_THING
        else
            totalWidth = totalWidth + renderGetFontDrawTextLength(font, part.text)
        end
    end

    local currentX = 0
    if alignment == MGSA_RENDER_ALIGNMENT_CENTER then
        currentX = x - (totalWidth / 2)
    elseif alignment == MGSA_RENDER_ALIGNMENT_LEFT then
        currentX = x
    end

    for _, part in ipairs(parts) do
        local barType, val = part.text:match("^#([hva]bar)#([%d%.]+)#$")

        if barType == "hbar" then
            __MGSARender__.renderHealthBar(font, tonumber(val) or 0, currentX + (SUS_THING / 2), y)
            currentX = currentX + SUS_THING
        elseif barType == "abar" then
            __MGSARender__.renderArmorBar(font, tonumber(val) or 0, currentX + (SUS_THING / 2), y)
            currentX = currentX + SUS_THING
        elseif barType == "vbar" then
            __MGSARender__.renderVehicleHealthBar(font, tonumber(val) or 0, currentX + (SUS_THING / 2), y)
            currentX = currentX + SUS_THING
        else
            renderFontDrawText(font, part.text, currentX, y, part.color)
            currentX = currentX + renderGetFontDrawTextLength(font, part.text)
        end
    end
end

function __MGSARender__.load()
    MGSA_LOADED_MODULE({
        name = "RenderUtils",
        desc = "Interni modul koji kompletnom sistemu pruza mogucnost efikasnog\n prikazivanja teksta i drugih vizuelnih elemenata."
    })
end

return __MGSARender__