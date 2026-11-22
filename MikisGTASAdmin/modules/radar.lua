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

local function getViewHeadingDegComplex()
    if isCharInAnyCar and doesCharExist and doesCharExist(PLAYER_PED) and isCharInAnyCar(PLAYER_PED) then
        local ok, car = pcall(storeCarCharIsInNoSave, PLAYER_PED)
        if ok and car and doesVehicleExist and doesVehicleExist(car) then
            local okH, h = pcall(getCarHeading, car)
            if okH and type(h) == "number" then
                return h
            end
        end
    end

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

    if doesCharExist and doesCharExist(PLAYER_PED) and getCharHeading then
        local okH, h = pcall(getCharHeading, PLAYER_PED)
        if okH and type(h) == "number" then
            return h
        end
    end

    return 0.0
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

local function worldToRadarRelative(wx, wy, myX, myY, cx, cy, radiusPx)
    local dx = (wx - myX) / radar.range
    local dy = (wy - myY) / radar.range
    local sx = cx + dx * radiusPx
    local sy = cy - dy * radiusPx
    return sx, sy
end

local function drawVisionCone(cx, cy, headingDeg, radiusPx, fovDeg, segments)
    radiusPx = radiusPx or 34
    fovDeg = fovDeg or 65
    segments = segments or 14

    local radCenter = math.rad(headingDeg)
    local halfFov = math.rad(fovDeg * 0.5)
    local startAngle = radCenter - halfFov
    local stepAngle = (halfFov * 2) / segments

    local coneColor = 0x3633CCFF

    for i = 0, segments - 1 do
        local a1 = startAngle + i * stepAngle
        local a2 = a1 + stepAngle

        local x1 = cx + (-math.sin(a1)) * radiusPx
        local y1 = cy - (math.cos(a1)) * radiusPx

        local x2 = cx + (-math.sin(a2)) * radiusPx
        local y2 = cy - (math.cos(a2)) * radiusPx

        if renderDrawTriangle then
            pcall(renderDrawTriangle, cx, cy, x1, y1, x2, y2, coneColor)
        else
            local mx = (x1 + x2) * 0.5
            local my = (y1 + y2) * 0.5
            for s = 2, 10, 2 do
                local t = s / 10
                local px = cx + (mx - cx) * t
                local py = cy + (my - cy) * t
                renderDrawBox(px - 1.5, py - 1.5, 3, 3, 0x2633CCFF)
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
        desc = "Radar sa pozicijom igraca, smjerom gledanja, bojom nicka i ID-evima!"
    })
end

local function drawRadar()
    local rx, ry, rw, rh = getRadarRect()
    local cx = rx + rw * 0.5
    local cy = ry + rh * 0.5
    local radiusPx = math.min(rw, rh) * 0.46

    renderDrawBox(rx - 2, ry - 2, rw + 4, rh + 4, 0xE610141A)
    renderDrawBox(rx, ry, rw, rh, 0xB3161C24)

    renderDrawBox(rx + rw * 0.5, ry, 1, rh, 0x26FFFFFF)
    renderDrawBox(rx, ry + rh * 0.5, rw, 1, 0x26FFFFFF)

    local half = radar.dotSize * 0.5
    local ok, nick, ped
    for id = 0, 1004 do
        if MGSA_API.sampIsPlayerConnected(id) then
            local px, py
            ok, ped = MGSA_API.sampGetCharHandleBySampPlayerId(id)
            if ok and ped and ped ~= -1 and doesCharExist(ped) and ped ~= PLAYER_PED then
                px, py, _ = getCharCoordinates(ped)
            end

            if px and py then
                local sx, sy = worldToRadarRelative(px, py, MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y, cx, cy, radiusPx)
                if sx >= rx and sx <= (rx + rw) and sy >= ry and sy <= (ry + rh) then
                    ok, nick = MGSA_API.sampGetPlayerColor(id)
                    if not ok then
                        nick = 0xffffffff
                    end
                    renderDrawBox(sx - half - 1, sy - half - 1, radar.dotSize + 2, radar.dotSize + 2, 0xE6000000)
                    renderDrawBox(sx - half, sy - half, radar.dotSize, radar.dotSize, nick)
                    drawPlayerId(id, sx, sy, nick)
                end
            end
        end
    end


    local h = getViewHeadingDeg()
    drawVisionCone(cx, cy, h, 36, 65, 16)
    renderDrawBox(cx - half - 1, cy - half - 1, radar.dotSize + 2, radar.dotSize + 2, 0xFF000000)
    renderDrawBox(cx - half, cy - half, radar.dotSize, radar.dotSize, 0xFF33CCFF)
end

function __MGSAMiniRadar__.loop()
    if not MGSA_MINIRADAR then return end
    drawRadar()
end

return __MGSAMiniRadar__