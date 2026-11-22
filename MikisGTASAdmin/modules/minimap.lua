local __MGSAMinimap__ = {}

local radar = {
    texture = nil,
    x=45,y=820,width=320,height=220,
    scale = 0.1,
    maptexture = nil
}

local WORLD_SIZE = 6000.0

function __MGSAMinimap__.load()
    radar.maptexture = getWorkingDirectory() ..
        "\\MikisGTASAdmin\\resources\\map.png"

    print("[MINIMAP] PATH: " .. radar.maptexture)
    print("[MINIMAP] FILE EXISTS: " ..
        tostring(doesFileExist(radar.maptexture)))

    if not doesFileExist(radar.maptexture) then
        print("[MINIMAP] MAP.PNG NIJE PRONADJEN!")
        return false
    end

    radar.texture = renderLoadTextureFromFile(radar.maptexture)

    print("[MINIMAP] TEXTURE: " .. tostring(radar.texture))

    if not radar.texture then
        print("[MINIMAP] GRESKA PRI UCITAVANJU TEKSTURE!")
        return false
    end

    MGSA_LOADED_MODULE({
        name = "Minimap",
        desc = "Prikazuje malu mapu sa pozicijama okolnih igraca!"
    })

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

local function drawMap(centerX, centerY)
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

    useRenderCommands(true)
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

function __MGSAMinimap__.loop()
    if not MGSA_MINIMAP then return end
    if not radar.texture then return end
    if isGamePaused() then return end
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