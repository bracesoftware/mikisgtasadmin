local __MGSAMiniRadar__ = {}

function __MGSAMiniRadar__.toggle()
    MGSA_MINIRADAR = not MGSA_MINIRADAR
    if MGSA_MINIRADAR then
        sendSuccessMessage("Uspjesno ste ukljucili radar modul!")
        return
    end
    sendWarningMessage("Iskljucili ste radar.")
end

----------------------------------------------------------

local radar = {
    x = 45,
    y = nil,
    width = 240,
    height = 240,
    range = 250.0,
    dotSize = 8
}

local function getRadarRect()
    local sw, sh = getScreenResolution()
    local w = radar.width
    local h = radar.height
    local x = radar.x
    local y = radar.y or (sh - h - 45)

    if x + w > sw then x = math.max(10, sw - w - 10) end
    if y + h > sh then y = math.max(10, sh - h - 10) end

    return x, y, w, h
end

local function getViewHeadingDeg()
    if getActiveCameraPointAt and getActiveCameraCoordinates and getHeadingFromVector2d then
        local ok1, x1, y1 = pcall(getActiveCameraPointAt)
        local ok2, x2, y2 = pcall(getActiveCameraCoordinates)
        if ok1 and ok2 and x1 and y1 and x2 and y2 then
            local okH, h = pcall(getHeadingFromVector2d, x1 - x2, y1 - y2)
            if okH and type(h) == "number" then
                return h
            end
        end
    end

    return 0.0
end

local function worldToRadarRelative(wx, wy, myx, myy, cx, cy, radiusPx)
    local dx = (wx - myx) / radar.range
    local dy = (wy - myy) / radar.range
    local sx = cx + dx * radiusPx
    local sy = cy - dy * radiusPx
    return sx, sy
end

local function worldToRadarRelativeComplex(wx, wy, myx, myy, cx, cy, radiusPx)
    local dx = (wx - myx) / radar.range
    local dy = (wy - myy) / radar.range
    local rr = radiusPx + 15
    local sx = dx * rr
    local sy = -dy * rr

    local distance = math.sqrt(sx * sx + sy * sy)
    local maxRadius = rr - radar.dotSize
    local outside = distance > maxRadius

    if outside and distance > 0 then
        local scale = maxRadius / distance
        sx = sx * scale
        sy = sy * scale
    end

    return cx + sx, cy + sy, outside
end
local function worldToRadarRelativeForPoints(a,b,c,d,e,f,g)
    local x,y,o = worldToRadarRelativeComplex(a,b,c,d,e,f,g)
    return x,y
end

local function drawVisionCone(cx, cy, headingDeg, radiusPx, fovDeg, segments, opacity)
    radiusPx = radiusPx or 34
    fovDeg = fovDeg or 65
    segments = segments or 14

    local radCenter = math.rad(headingDeg)
    local halfFov = math.rad(fovDeg * 0.5)
    local startAngle = radCenter - halfFov
    local stepAngle = (halfFov * 2) / segments

    local col = MGSARender.setColorOpacity(MGSA_STICKMAN_COLOR,opacity)

    for i = 0, segments - 1 do
        local a1 = startAngle + i * stepAngle
        local a2 = a1 + stepAngle

        local x1 = cx + (-math.sin(a1)) * radiusPx
        local y1 = cy - (math.cos(a1)) * radiusPx

        local x2 = cx + (-math.sin(a2)) * radiusPx
        local y2 = cy - (math.cos(a2)) * radiusPx

        if renderDrawTriangle then
            pcall(renderDrawTriangle, cx, cy, x1, y1, x2, y2, col)
        else
            local mx = (x1 + x2) * 0.5
            local my = (y1 + y2) * 0.5
            for s = 2, 10, 2 do
                local t = s / 10
                local px = cx + (mx - cx) * t
                local py = cy + (my - cy) * t
                renderDrawBox(px - 1.5, py - 1.5, 3, 3, col)
            end
        end
    end
end

local function drawPlayerId(id, sx, sy, col)
    if not id or id < 0 then return end
    renderFontDrawText(MGSA_FONT_SMALL, tostring(id), math.floor(sx + 6), math.floor(sy - 6), col)
end

function __MGSAMiniRadar__.load()
    MGSA_LOADED_MODULE({
        name = "MiniRadar",
        desc = "Jednostavan sistem radara koji otkriva poziciju okolnih igraca!"
    })
end

local function canFitIntoRadar(sx,sy,rx,ry,rw,rh)
    return sx >= rx and sx <= (rx + rw) and sy >= ry and sy <= (ry + rh)
end

MGSA_PICKUP_DATA = {
    MODEL_BITMAPS = MGSA_API.sampGetPickupModelBitmaps(),
    POOL = nil,
    TIMER = nil
}

MGSA_PICKUP_DATA.TIMER = MGSA_CHRONO.task(
    0.1, function (id)
        MGSA_PICKUP_DATA.POOL = MGSA_API.sampGetPickupPool()
    end, true
)

local OPACITY_RANGE = 35
local ICON_OPACITY = 0
local MODE = 0
MGSA_CHRONO.task(0.01, function (id)
    if MODE == 0 then
        ICON_OPACITY = ICON_OPACITY + 1
    else
        ICON_OPACITY = ICON_OPACITY - 1
    end
    if ICON_OPACITY > 100 then
        ICON_OPACITY = 100
        MODE = 1
    elseif ICON_OPACITY < OPACITY_RANGE then
        MODE = 0
        ICON_OPACITY = OPACITY_RANGE
    end
end, true)

local function drawRadar()
    local rx, ry, rw, rh = getRadarRect()
    local cx = rx + rw * 0.5
    local cy = ry + rh * 0.5
    local radiusPx = math.min(rw, rh) * 0.46

    renderDrawBox(rx - 2, ry - 2, rw + 4, rh + 4, 0xE610141A)
    renderDrawBox(rx, ry, rw, rh, 0xB3161C24)

    renderDrawBox(rx + rw * 0.5, ry, 1, rh, 0x26FFFFFF)
    renderDrawBox(rx, ry + rh * 0.5, rw, 1, 0x26FFFFFF)

    for i = 1, 5 do
        MGSARender.drawCircle(cx,cy, i * 21, 0x26FFFFFF,64)
    end

    if MGSA_PICKUP_DATA.POOL ~= nil then
        for i, p in ipairs(MGSA_PICKUP_DATA.POOL) do
            if MGSA_PICKUP_DATA.MODEL_BITMAPS[p.model] then
                local pm = MGSA_PICKUP_DATA.MODEL_BITMAPS[p.model]
                local sx, sy = worldToRadarRelative(p.x, p.y, MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y, cx, cy, radiusPx)
                if canFitIntoRadar(sx,sy,rx,ry,rw,rh) then
                    MGSARender.drawBitmapCentered(
                        pm.bitmap, sx, sy,
                        MGSARender.setColorOpacity(pm.color, ICON_OPACITY), 2
                    )
                end
            end
        end
    end

    local half = radar.dotSize * 0.5
    local result, x, y, z = getTargetBlipCoordinates()
    if result then
        local sx,sy = worldToRadarRelativeForPoints(x,y,MGSA_PLAYER_POS.x,MGSA_PLAYER_POS.y,cx,cy,radiusPx)
        if canFitIntoRadar(sx,sy,rx,ry,rw,rh) then
            renderDrawBox(sx - half - 1, sy - half - 1, radar.dotSize + 2, radar.dotSize + 2, 0xFF000000)
            renderDrawBox(sx - half, sy - half, radar.dotSize, radar.dotSize, MGSA_STICKMAN_COLOR)
        end
    end

    local ok, nick, ped
    for id = 0, MGSA_API.sampGetLargestPlayerId() do
        if MGSA_API.sampIsPlayerConnected(id) then
            local px, py
            ok, ped = MGSA_API.sampGetCharHandleBySampPlayerId(id)
            if ok and ped and ped ~= -1 and doesCharExist(ped) and ped ~= PLAYER_PED then
                px, py, _ = getCharCoordinates(ped)
            end

            if px and py then
                local sx, sy = worldToRadarRelative(px, py, MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y, cx, cy, radiusPx)
                if canFitIntoRadar(sx,sy,rx,ry,rw,rh) then
                    ok, nick = MGSA_API.sampGetPlayerColor(id)
                    if not ok then
                        nick = 0xffffffff
                    end
                    renderDrawBox(sx - half - 1, sy - half - 1, radar.dotSize + 2, radar.dotSize + 2, 0xE6000000)
                    renderDrawBox(sx - half, sy - half, radar.dotSize, radar.dotSize, nick)
                    drawPlayerId(id, sx, sy, 0xffffffff)
                end
            end
        end
    end

    local h = getViewHeadingDeg()
    drawVisionCone(cx, cy, h, 36, 65, 16, ICON_OPACITY - 20)
    renderDrawBox(cx - half - 1, cy - half - 1, radar.dotSize + 2, radar.dotSize + 2, 0xFF000000)
    renderDrawBox(cx - half, cy - half, radar.dotSize, radar.dotSize, MGSA_STICKMAN_COLOR)
end

function __MGSAMiniRadar__.loop()
    if not MGSA_MINIRADAR then return end
    drawRadar()
end

return __MGSAMiniRadar__