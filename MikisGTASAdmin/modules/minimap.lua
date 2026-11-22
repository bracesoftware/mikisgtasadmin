local __MGSAMinimap__ = {}

local radar = {
    texture = nil,
    x=20,y=820,width=350,height=200,
    scale = 0.1,
    maptexture = nil
}

local WORLD_SIZE = 6000.0

function __MGSAMinimap__.load()
    radar.maptexture = getWorkingDirectory() .. "MikisGTASAdmin/resources/map.png"
    MGSA_LOADED_MODULE(
        {
            name = "Minimap",
            desc = "Prikazuje malu mapu sa pozicijama okolnih igrača!"
        }
    )
    radar.texture = renderLoadTextureFromFile(radar.maptexture)
    if not radar.texture then
        print("NE VALJA PATH ILI TEXTURA")
        return false
    end

    return true
end

function __MGSAMinimap__.unload()
    if radar.texture then
        renderReleaseTexture(radar.texture)
        radar.texture = nil
    end
end

local function worldToMap(x,y)
    return (x + WORLD_SIZE / 2) / WORLD_SIZE, (-y + WORLD_SIZE / 2) / WORLD_SIZE
end

local function drawMapOld(centerX, centerY)
    local ratio = radar.width / radar.height
    local centerU, centerV = worldToMap(centerX, centerY)
    local halfU, halfV
    if ratio >= 1 then
        halfU = radar.scale
        halfV = radar.scale / ratio
    else
        halfU = radar.scale * ratio
        halfV = radar.scale
    end

    local u1 = centerU - halfU
    local v1 = centerV - halfV
    local u2 = centerU + halfU
    local v2 = centerV + halfV

    renderBindTexture(radar.texture)
    renderColor(0xFFFFFFFF)

    renderBegin(5)

        renderSetTexCoord(u1, v1)
        renderVertex(radar.x, radar.y)

        renderSetTexCoord(u2, v1)
        renderVertex(radar.x + radar.width, radar.y)

        renderSetTexCoord(u1, v2)
        renderVertex(radar.x, radar.y + radar.height)

        renderSetTexCoord(u2, v2)
        renderVertex(radar.x + radar.width, radar.y + radar.height)

    renderEnd()

    --renderBindTexture(nil)
end

local function drawMap()
    if not radar.texture then return end

    renderBindTexture(radar.texture)
    renderColor(0xFFFFFFFF)

    renderBegin(5)

        renderSetTexCoord(0.0, 0.0)
        renderVertex(radar.x, radar.y)

        renderSetTexCoord(1.0, 0.0)
        renderVertex(radar.x + radar.width, radar.y)

        renderSetTexCoord(0.0, 1.0)
        renderVertex(radar.x, radar.y + radar.height)

        renderSetTexCoord(1.0, 1.0)
        renderVertex(radar.x + radar.width, radar.y + radar.height)

    renderEnd()
end

function __MGSAMinimap__.loop()
    if not MGSA_MINIMAP then return end
    --if not radar.texture then return end
    --if isGamePaused() then return end
    drawMap(MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y)
end

function __MGSAMinimap__.toggle()
    MGSA_MINIMAP = not MGSA_MINIMAP
    if MGSA_MINIMAP then
        sendSuccessMessage("Uspjesno ste ukljucili minimap modul!")
        return
    end
    sendWarningMessage("Iskljucili ste mapu.")
end

return __MGSAMinimap__