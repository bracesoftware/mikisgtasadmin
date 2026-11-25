local __MGSAWallhack__ = {}

local MGSA_STICKMAN_COLORS = {
    TURQOISE,
    BRIGHT_TURQOISE,
    LJUBICASTA
}
local MGSA_STICKMAN_COLOR_IDX = 1
MGSA_STICKMAN_COLOR = MGSA_STICKMAN_COLORS[MGSA_STICKMAN_COLOR_IDX]
local lastTime = 0
---------------------------------------------------

--------------------------------------------------------
function __MGSAWallhack__.update()
    local currentTime = os.clock()
    if currentTime - lastTime >= 0.76 then
        lastTime = currentTime
        MGSA_STICKMAN_COLOR_IDX = MGSA_STICKMAN_COLOR_IDX + 1
        if MGSA_STICKMAN_COLOR_IDX > #MGSA_STICKMAN_COLORS then
            MGSA_STICKMAN_COLOR_IDX = 1
        end
        MGSA_STICKMAN_COLOR = MGSA_STICKMAN_COLORS[MGSA_STICKMAN_COLOR_IDX]
    end
end

--------------------------

local function MGSA_GET_WEAPON_AMMO(id)
    if not MGSA_API.sampIsPlayerConnected(id) then
        return 0
    end

    local result, ped = MGSA_API.sampGetCharHandleBySampPlayerId(id)

    if not result or not doesCharExist(ped) then
        return 0
    end

    local weapon = getCurrentCharWeapon(ped)

    if weapon < 22 or weapon > 38 then
        return 0
    end

    return getAmmoInCharWeapon(ped, weapon) or 0
end

--takes ped handle

local function MGSA_GET_SPEED(ped)
    if not doesCharExist(ped) then return 0 end

    local vx, vy, vz = 0, 0, 0
    if isCharInAnyCar(ped) then
        local veh = storeCarCharIsInNoSave(ped)
        if doesVehicleExist(veh) then
            return getCarSpeed(veh)
        end
    else
        vx, vy, vz = getCharVelocity(ped)
    end

    return math.sqrt(vx*vx + vy*vy + vz*vz)
end


local MGSA_GTA_VEHICLE_NAMES = {
    [400] = "Landstalker", [401] = "Bravura", [402] = "Buffalo", [403] = "Linerunner", [404] = "Perennial",
    [405] = "Sentinel", [406] = "Dumper", [407] = "Firetruck", [408] = "Trashmaster", [409] = "Stretch",
    [410] = "Manana", [411] = "Infernus", [412] = "Voodoo", [413] = "Pony", [414] = "Mule",
    [415] = "Cheetah", [416] = "Ambulance", [417] = "Leviathan", [418] = "Moonbeam", [419] = "Esperanto",
    [420] = "Taxi", [421] = "Washington", [422] = "Bobcat", [423] = "Mr Whoopee", [424] = "BF Injection",
    [425] = "Hunter", [426] = "Premier", [427] = "Enforcer", [428] = "Securicar", [429] = "Banshee",
    [430] = "Predator", [431] = "Bus", [432] = "Rhino", [433] = "Barracks", [434] = "Hotknife",
    [435] = "Article Trailer", [436] = "Previon", [437] = "Coach", [438] = "Cabbie", [439] = "Stallion",
    [440] = "Rumpo", [441] = "RC Bandit", [442] = "Romero", [443] = "Packer", [444] = "Monster",
    [445] = "Admiral", [446] = "Squallo", [447] = "Seasparrow", [448] = "Pizzaboy", [449] = "Tram",
    [450] = "Trailer 2", [451] = "Turismo", [452] = "Speeder", [453] = "Reefer", [454] = "Tropic",
    [455] = "Flatbed", [456] = "Yankee", [457] = "Caddy", [458] = "Solair", [459] = "Berkley's RC Van",
    [460] = "Skimmer", [461] = "PCJ-600", [462] = "Faggio", [463] = "Freeway", [464] = "RC Baron",
    [465] = "RC Raider", [466] = "Glendale", [467] = "Oceanic", [468] = "Sanchez", [469] = "Sparrow",
    [470] = "Patriot", [471] = "Quad", [472] = "Coastguard", [473] = "Dinghy", [474] = "Hermes",
    [475] = "Sabre", [476] = "Rustler", [477] = "ZR-350", [478] = "Walton", [479] = "Regina",
    [480] = "Comet", [481] = "BMX", [482] = "Burrito", [483] = "Camper", [484] = "Marquis",
    [485] = "Baggage", [486] = "Dozer", [487] = "Maverick", [488] = "VCN Maverick", [489] = "Rancher",
    [490] = "FBI Rancher", [491] = "Virgo", [492] = "Greenwood", [493] = "Jetmax", [494] = "Hotring Racer",
    [495] = "Sandking", [496] = "Blista Compact", [497] = "Police Maverick", [498] = "Boxville", [499] = "Benson",
    [500] = "Mesa", [501] = "RC Goblin", [502] = "Hotring Racer A", [503] = "Hotring Racer B", [504] = "Bloodring Banger",
    [505] = "Rancher", [506] = "Super GT", [507] = "Elegant", [508] = "Journey", [509] = "Bike",
    [510] = "Mountain Bike", [511] = "Beagle", [512] = "Cropduster", [513] = "Stuntplane", [514] = "Tanker",
    [515] = "Roadtrain", [516] = "Nebula", [517] = "Majestic", [518] = "Buccaneer", [519] = "Shamal",
    [520] = "Hydra", [521] = "FCR-900", [522] = "NRG-500", [523] = "HPV1000", [524] = "Cement Truck",
    [525] = "Towtruck", [526] = "Fortune", [527] = "Cadrona", [528] = "FBI Truck", [529] = "Willard",
    [530] = "Forklift", [531] = "Tractor", [532] = "Combine Harvester", [533] = "Feltzer", [534] = "Remington",
    [535] = "Slamvan", [536] = "Blade", [537] = "Freight (Train)", [538] = "Brownstreak (Train)", [539] = "Vortex",
    [540] = "Vincent", [541] = "Bullet", [542] = "Clover", [543] = "Sadler", [544] = "Firetruck LA",
    [545] = "Hustler", [546] = "Intruder", [547] = "Primo", [548] = "Cargobob", [549] = "Tampa",
    [550] = "Sunrise", [551] = "Merit", [552] = "Utility Van", [553] = "Nevada", [554] = "Yosemite",
    [555] = "Windsor", [556] = "Monster A", [557] = "Monster B", [558] = "Uranus", [559] = "Jester",
    [560] = "Sultan", [561] = "Stratum", [562] = "Elegy", [563] = "Raindance", [564] = "RC Tiger",
    [565] = "Flash", [566] = "Tahoma", [567] = "Savanna", [568] = "Bandito", [569] = "Freight Flatbed",
    [570] = "Streak Carriage", [571] = "Kart", [572] = "Mower", [573] = "Dune", [574] = "Sweeper",
    [575] = "Broadway", [576] = "Tornado", [577] = "AT-400", [578] = "DFT-30", [579] = "Huntley",
    [580] = "Stafford", [581] = "BF-400", [582] = "Newsvan", [583] = "Tug", [584] = "Petrol Trailer",
    [585] = "Emperor", [586] = "Wayfarer", [587] = "Euros", [588] = "Hotdog", [589] = "Club",
    [590] = "Freight Box Trailer", [591] = "Article Trailer 3", [592] = "Andromada", [593] = "Dodo", [594] = "RC Cam",
    [595] = "Launch", [596] = "Police Car (LSPD)", [597] = "Police Car (SFPD)", [598] = "Police Car (LVPD)", [599] = "Police Ranger",
    [600] = "Picador", [601] = "S.W.A.T.", [602] = "Alpha", [603] = "Phoenix", [604] = "Glendale Shit",
    [605] = "Sadler Shit", [606] = "Baggage Trailer A", [607] = "Baggage Trailer B", [608] = "Tug Stairs Trailer", [609] = "Boxville",
    [610] = "Farm Trailer", [611] = "Utility Trailer"
}

local function MGSA_GET_VEHICLE_INFO(ped)
    if not doesCharExist(ped) then
        return -1,-1, "Nema"
    end

    if isCharInAnyCar(ped) then
        local veh = storeCarCharIsInNoSave(ped)
        if doesVehicleExist(veh) then
            local i = getCarModel(veh)
            local m = MGSA_GTA_VEHICLE_NAMES[i] or ("Nepoznato")
            return veh, i, m
        end
    end

    return -1,-1, "Pjeske"
end

--------------------------------------------

local function MGSA_DRAW_INDIVIDUAL_BONE(ped, bone1, bone2, color)
    local mad = MGSA_MOONADDITIONS

    if not doesCharExist(ped) then
        return nil
    end

    local b1 = mad.get_char_bone(ped, bone1)
    local b2 = mad.get_char_bone(ped, bone2)

    if not b1 or not b2 then
        return nil
    end

    local x1, y1, z1 = b1.matrix.pos:get()
    local x2, y2, z2 = b2.matrix.pos:get()

    local sx1, sy1 = convert3DCoordsToScreen(x1, y1, z1)
    local sx2, sy2 = convert3DCoordsToScreen(x2, y2, z2)

    if not sx1 or not sy1 or not sx2 or not sy2 then
        return nil
    end

    renderDrawLine(sx1, sy1, sx2, sy2, 4.0, color)

    local dx = math.abs(sx1 - sx2)
    local dy = math.abs(sy1 - sy2)

    return {
        distance = math.sqrt(dx * dx + dy * dy),
        firstpos = {
            x = sx1,
            y = sy1
        },
        secondpos = {
            x = sx2,
            y = sy2
        }
    }
end

local function MGSA_DRAWLINE_POINTS(point1, point2, thickness, col)
    renderDrawLine(
        point1[1], point1[2],
        point2[1], point2[2],
        thickness, col
    )
end

local function MGSA_RENDER_STICKMAN(ped, color)
    local BONE_HEAD          = 8
    local BONE_NECK          = 5
    local BONE_SPINE         = 3
    local BONE_PELVIS        = 0
    local BONE_LEFT_SHOULDER = 22
    local BONE_LEFT_ELBOW    = 23
    local BONE_LEFT_HAND     = 24
    local BONE_RIGHT_SHOULDER= 32
    local BONE_RIGHT_ELBOW   = 33
    local BONE_RIGHT_HAND    = 34
    local BONE_LEFT_HIP      = 51
    local BONE_LEFT_KNEE     = 52
    local BONE_LEFT_FOOT     = 53
    local BONE_RIGHT_HIP     = 41
    local BONE_RIGHT_KNEE    = 42
    local BONE_RIGHT_FOOT    = 43

    local headinfo = MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_HEAD, BONE_NECK, color)
    local info = MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_NECK, BONE_SPINE, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_SPINE, BONE_PELVIS, color)

    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_RIGHT_SHOULDER, BONE_LEFT_SHOULDER, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_LEFT_SHOULDER, BONE_LEFT_ELBOW, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_LEFT_ELBOW, BONE_LEFT_HAND, color)

    --MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_LEFT_SHOULDER, BONE_RIGHT_SHOULDER, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_RIGHT_SHOULDER, BONE_RIGHT_ELBOW, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_RIGHT_ELBOW, BONE_RIGHT_HAND, color)

    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_PELVIS, BONE_LEFT_HIP, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_LEFT_HIP, BONE_LEFT_KNEE, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_LEFT_KNEE, BONE_LEFT_FOOT, color)

    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_PELVIS, BONE_RIGHT_HIP, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_RIGHT_HIP, BONE_RIGHT_KNEE, color)
    MGSA_DRAW_INDIVIDUAL_BONE(ped, BONE_RIGHT_KNEE, BONE_RIGHT_FOOT, color)
    if not info or not headinfo then
        print("KRITICNO!!")
        return
    end
    local dis = info.distance

    MGSARender.drawCircleWithThickness(
        headinfo.firstpos.x, headinfo.firstpos.y - headinfo.distance * 2,
        dis / 4, MGSA_STICKMAN_COLOR, 32, 4.0
    )

    if isCharInAnyCar(ped) then
        return
    end
    local x, y, z = getCharCoordinates(ped)
    local sx, sy = convert3DCoordsToScreen(x, y, z)
    local col = NICE_PURPLE

    if not dis or not sx or not sy then
        return
    end

    local BOTTOM_LEFT = {sx - dis, sy + 2 * dis}
    local BOTTOM_RIGHT = {sx + dis, sy + 2 * dis}
    local TOP_LEFT = {sx - dis, sy - 2 * dis}
    local TOP_RIGHT = {sx + dis, sy - 2 * dis}

    MGSA_DRAWLINE_POINTS(BOTTOM_LEFT, BOTTOM_RIGHT, 1.0, col)
    MGSA_DRAWLINE_POINTS(TOP_LEFT, TOP_RIGHT, 1.0, col)
    MGSA_DRAWLINE_POINTS(TOP_LEFT, BOTTOM_LEFT, 1.0, col)
    MGSA_DRAWLINE_POINTS(TOP_RIGHT, BOTTOM_RIGHT, 1.0, col)
end


local function MGSA_GET_PLAYER_HEALTH_ARMOR(id)
    local hp = MGSA_API.sampGetPlayerHealth(id)
    local armor = MGSA_API.sampGetPlayerArmor(id)
    return hp or 0, armor or 0
end

----------------------------------------------

local function MGSA_COMPLEX_LABEL_RENDER(font,x,y,parts)
    return MGSARender.renderComplexLabel(font,x,y,parts,MGSA_RENDER_ALIGNMENT_CENTER)   
end

function __MGSAWallhack__.toggle()
    MGSA_TRACE("WALLHACK ENTER")

    MGSA_WALLHACK = not MGSA_WALLHACK

    if MGSA_WALLHACK then
        MGSAAltChat.send(
            {{
                text = "Wallhack ",
                color = CRVENA
            },
            {
                text = "ukljucen!",
                color = ZELENA
            }}
        )
    else
        MGSAAltChat.send(
            {{
                text = "Wallhack ",
                color = CRVENA
            },
            {
                text = "iskljucen!",
                color = SIVA
            }}
        )
    end

    MGSA_TRACE("WALLHACK EXIT")
end



function __MGSAWallhack__.load()

    if MGSA_FONTS_FAILED then
        sendErrorMessage("Ne mogu kreirati ESP font!")
        return
    end

    MGSA_LOADED_MODULE({
        name = "Wallhack",
        desc = "Omogucava da vidite informacije o udaljenim igracima i vozilima."
    })
end

local function MGSA_RENDER_ONE(id)
    if MGSA_API.sampIsPlayerConnected(id) then
        local result, ped = MGSA_API.sampGetCharHandleBySampPlayerId(id)
        if result and doesCharExist(ped) then
            local x, y, z = getCharCoordinates(ped)
            local sx, sy = convert3DCoordsToScreen(x, y, z)
            if sx and sy then
                local sw, sh = getScreenResolution()
                if isCharOnScreen(ped) then
                    local distance = getDistanceBetweenCoords3d(
                        MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y, MGSA_PLAYER_POS.z,
                        x, y, z
                    )

                    local score = MGSA_API.sampGetPlayerScoreFromPool(id)
                    local ping = MGSA_API.sampGetPlayerPingFromPool(id)
                    local nickname = MGSA_API.sampGetPlayerNicknameFromPool(id)
                    local hp, armor = MGSA_GET_PLAYER_HEALTH_ARMOR(id)
                    local speed = MGSA_GET_SPEED(ped)
                    local vhandle, vehid, vehname = MGSA_GET_VEHICLE_INFO(ped)
                    local wid,weapon = MGSA_API.sampGetPlayerWeaponInfoFromPool(id)
                    --local ammo = MGSA_GET_WEAPON_AMMO(id)
                    local skin = MGSA_API.sampGetPlayerSkinModelFromPool(id)
                    local col = MGSA_API.sampGetPlayerColorFromPool(id)
                    local afk = MGSA_API.sampIsPlayerPossiblyAwayFromPool(id)
                    --------------------------------------
                    local font = MGSA_FONT
                    local linesize = 15
                    if distance > 150 or (not distance) then
                        font = MGSA_FONT_SMALL
                        linesize = 12
                    end
                    --------------------------------------
                    MGSA_RENDER_STICKMAN(ped, MGSA_STICKMAN_COLOR)
                    sy = sy - linesize * 3

                    if isCharInAnyCar(ped) then
                        MGSA_PLAYER_VEH_MAP[vhandle] = MGSA_PLAYER_VEH_MAP[vhandle] or {}
                        table.insert(MGSA_PLAYER_VEH_MAP[vhandle], id)
                        return
                    end

                    MGSA_COMPLEX_LABEL_RENDER(
                        font, sx, sy,
                        {
                            {
                                text = string.format("%d ms"..MGSA_TAB, ping),
                                color = MGSA_GET_PING_COLOR(ping)
                            },
                            {
                                text = string.format("(%d) %s ", id, nickname),
                                color = col
                            },
                            {
                                text = string.format("[%.0f m | %.0f km/h]", distance, speed * 3),
                                color = MASLINASTA
                            }
                        }
                    )
                    MGSARender.renderHealthBar(font, hp, sx, sy + linesize)
                    MGSARender.renderArmorBar(font, armor, sx, sy + 2 * linesize)
                    if afk then
                        MGSARender.renderCenteredText(
                            font, "Moguc AFK!", sx, sy + linesize * 3, SIVA
                        )
                    end
                    MGSA_COMPLEX_LABEL_RENDER(
                        font, sx, sy + linesize * 4,
                        {
                            {
                                text = "Vozilo: ",
                                color = ZUTA
                            },
                            {
                                text = "(-1) Pjeske"..MGSA_TAB,--string.format("(%d) %s"..MGSA_TAB, vehid, vehname),
                                color = LIGHT_GRAY
                            },
                            {
                                text = "Level: ",
                                color = BLUE_AS_SEA
                            },
                            {
                                text = string.format("%d", score),
                                color = SVIJETLO_SIVA
                            }
                        }
                    )

                    MGSA_COMPLEX_LABEL_RENDER(
                        font, sx, sy + linesize * 5,
                        {
                            {
                                text = "Skin: ",
                                color = ORANGE
                            },
                            {
                                text = string.format("%d"..MGSA_TAB, skin),
                                color = LIGHT_GRAY
                            },
                            {
                                text = "Oruzje: ",
                                color = GOLD
                            },
                            {
                                text = string.format("(%d) %s",wid, weapon),
                                color = LIGHT_GRAY
                            }
                        }
                    )
                end
            end
        end
    end
end


local function MGSA_GET_VEHICLE_CORNERS_2D(v)
    local model = getCarModel(v)

    local minX, minY, minZ, maxX, maxY, maxZ =
        getModelDimensions(model)

    local corners = {
        {minX, maxY, minZ}, -- Front Left
        {maxX, maxY, minZ}, -- Front Right
        {minX, minY, minZ}, -- Rear Left (placeholder)
        {maxX, minY, minZ}  -- Rear Right
    }

    local corners2d = {}

    for i = 1, 4 do
        local x, y, z = getOffsetFromCarInWorldCoords(
            v,
            corners[i][1],
            corners[i][2],
            corners[i][3]
        )

        local sx, sy = convert3DCoordsToScreen(x, y, z)

        corners2d[i] = {sx, sy}
    end

    return corners2d
end


local function MGSA_RENDER_VEHICLES()
    for vhandle, playerids in pairs(MGSA_PLAYER_VEH_MAP) do
        if doesVehicleExist(vhandle) then
            local x,y,z = getCarCoordinates(vhandle)
            local distance = getDistanceBetweenCoords3d(
                MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y, MGSA_PLAYER_POS.z,
                x, y, z
            )
            local sx, sy = convert3DCoordsToScreen(x,y,z)
            if sx and sy then
                local pos = MGSA_GET_VEHICLE_CORNERS_2D(vhandle)

                if pos[1][1] and pos[1][2]
                and pos[2][1] and pos[2][2]
                and pos[3][1] and pos[3][2]
                and pos[4][1] and pos[4][2] then
                    MGSA_DRAWLINE_POINTS(pos[1], pos[2], 1.0, NICE_PURPLE)
                    MGSA_DRAWLINE_POINTS(pos[3], pos[4], 1.0, NICE_PURPLE)
                    MGSA_DRAWLINE_POINTS(pos[2], pos[4], 1.0, NICE_PURPLE)
                    MGSA_DRAWLINE_POINTS(pos[1], pos[3], 1.0, NICE_PURPLE)
                    --x
                    MGSA_DRAWLINE_POINTS(pos[1], pos[4], 1.0, NICE_PURPLE)
                    MGSA_DRAWLINE_POINTS(pos[2], pos[3], 1.0, NICE_PURPLE)
                end

                local vehid = getCarModel(vhandle)
                local vehname = MGSA_GTA_VEHICLE_NAMES[vehid] or "Nepoznato"
                local speed = getCarSpeed(vhandle) * 3
                sy = sy - 50

                local fonttt = MGSA_FONT_BOLD
                if distance > 100 or not distance then
                    fonttt = MGSA_FONT_SMALL
                end

                MGSA_COMPLEX_LABEL_RENDER(
                    fonttt, sx, sy,
                    {
                        {
                            text = "Vozilo: ",
                            color = ORANGE
                        },
                        {
                            text = string.format("(%d) %s ", vehid, vehname),
                            color = LIGHT_GRAY
                        },
                        {
                            text = string.format("[%.0f m | %.0f km/h]", distance, speed),
                            color = MASLINASTA
                        },
                        {
                            vbar = getCarHealth(vhandle),
                            color = MASLINASTA
                        }
                    }
                )

                local lineY = sy + 15
                for _, id in ipairs(playerids) do
                    if MGSA_API.sampIsPlayerConnected(id) then
                        local nick = MGSA_API.sampGetPlayerNicknameFromPool(id)
                        local col = MGSA_API.sampGetPlayerColorFromPool(id)
                        local hp, armor = MGSA_GET_PLAYER_HEALTH_ARMOR(id)
                        local skin = MGSA_API.sampGetPlayerSkinModelFromPool(id)
                        local ping = MGSA_API.sampGetPlayerPingFromPool(id)
                        local score = MGSA_API.sampGetPlayerScoreFromPool(id)

                        MGSA_COMPLEX_LABEL_RENDER(
                            MGSA_FONT_SMALL, sx, lineY,
                            {
                                {
                                    text = string.format("%d ms"..MGSA_TAB, ping),
                                    color = MGSA_GET_PING_COLOR(ping)
                                },
                                {
                                    text = string.format("(%d) %s"..MGSA_TAB, id,nick),
                                    color = col
                                },
                                {
                                    hbar = hp,
                                    color = CRVENA
                                },
                                {
                                    abar = armor,
                                    color = BIJELA
                                },
                                {
                                    text = "Skin: ",
                                    color = GOLD
                                },
                                {
                                    text = string.format("%d"..MGSA_TAB, skin),
                                    color = SVIJETLO_SIVA
                                },
                                {
                                    text = "Level: ",
                                    color = BLUE_AS_SEA
                                },
                                {
                                    text = string.format("%d", score),
                                    color = SVIJETLO_SIVA
                                }
                            }
                        )

                        lineY = lineY + 13
                    end
                end
            end
        end
    end
end

function __MGSAWallhack__.render()
    if not MGSA_WALLHACK or MGSA_FONTS_FAILED then return end

    MGSA_PLAYER_VEH_MAP = {}

    for id = 0, MGSA_API.sampGetLargestPlayerId() do
        MGSA_RENDER_ONE(id)
    end
    MGSA_RENDER_VEHICLES()
end

return __MGSAWallhack__