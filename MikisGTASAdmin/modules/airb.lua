local __MGSAAirBreak__ = {}


function __MGSAAirBreak__.toggle()
    MGSA_AIRBREAK = not MGSA_AIRBREAK
    sendWarningMessage("Promijenjen status airbreaka!")
    if MGSA_AIRBREAK then
        MGSAAltChat.send(
            {
                {
                    text = "AirBreak ",
                    color = CRVENA
                },
                {
                    text = "ukljucen!",
                    color = ZELENA
                }
            }
        )
        return
    end
    MGSAAltChat.send(
        {
            {
                text = "AirBreak ",
                color = CRVENA
            },
            {
                text = "iskljucen!",
                color = SIVA
            }
        }
    )
end
----------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

local active = false
local speed = 0.65
local MGSA_AIRBREAK_DATA = {
    start_z = 0,
    offset_z = 0.06, --setting
    speedModifier = 5.0
}

function __MGSAAirBreak__.getKeyCombination()
    return {
        text = "'B + ENTER'",
        keys = {
            MGSA_KEY_B, MGSA_KEY_ENTER
        }
    }
end

function __MGSAAirBreak__.load()
    MGSA_LOADED_MODULE(
        {
            name = "AirBreak",
            desc = "Omogucava da se krecete slobodno kroz zrak.\n"
            .."Airbreak rezim kretanja palite klikom na "..__MGSAAirBreak__.getKeyCombination().text.."."
        }
    )
end
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

function __MGSAAirBreak__.loop()
    if not MGSA_AIRBREAK then
        active = false
        return
    end

    if MGSA_API.isKeyCombinationUsed(__MGSAAirBreak__.getKeyCombination().keys) then
        active = not active
        if active then
            setCharVelocity(PLAYER_PED, 0.0, 0.0, 0.0)
            MGSA_AIRBREAK_DATA.start_z = MGSA_PLAYER_POS.z
        end
        MGSAAltChat.send({
            {
                text = "[Air-Break] ",
                color = TURQOISE
            },
            {
                text = active
                    and "Uspjesno ste pokrenuli airbreak rezim kretanja!"
                    or "Uspjesno ste iskljucili airbreak rezim kretanja!",
                color = SVIJETLO_SIVA
            }
        })
        return
    end

    if not active then return end
    if not (
        not MGSA_API.isSampChatOpened()
        and not MGSA_API.isSampDialogOnScreen()
        and not MGSACommandInput.isCommandConsoleOpen()
    ) then return end

    setCharVelocity(PLAYER_PED, 0.0, 0.0, 0.0)

    local dx, dy, dz = 0.0, 0.0, 0.0
    local cx, cy, cz = getActiveCameraCoordinates()
    local tx, ty, tz = getActiveCameraPointAt()
    local fx = tx - cx
    local fy = ty - cy
    local len = math.sqrt(fx * fx + fy * fy)
    if len > 0.0001 then
        fx = fx / len
        fy = fy / len
    else
        return
    end
    --horizontala bajo
    if isKeyDown(MGSA_KEY_W) then
        dx = dx + fx / MGSA_AIRBREAK_DATA.speedModifier
        dy = dy + fy / MGSA_AIRBREAK_DATA.speedModifier
    end
    if isKeyDown(MGSA_KEY_S) then
        dx = dx - fx / MGSA_AIRBREAK_DATA.speedModifier
        dy = dy - fy / MGSA_AIRBREAK_DATA.speedModifier
    end
    if isKeyDown(MGSA_KEY_D) then
        dx = dx + fy / MGSA_AIRBREAK_DATA.speedModifier
        dy = dy - fx / MGSA_AIRBREAK_DATA.speedModifier
    end
    if isKeyDown(MGSA_KEY_A) then
        dx = dx - fy / MGSA_AIRBREAK_DATA.speedModifier
        dy = dy + fx / MGSA_AIRBREAK_DATA.speedModifier
    end

    --vertikala bajo
    if isKeyDown(MGSA_KEY_SPACE) then
        dz = dz + MGSA_AIRBREAK_DATA.offset_z
    end
    if isKeyDown(MGSA_KEY_LSHIFT) then
        dz = dz - MGSA_AIRBREAK_DATA.offset_z
    end

    if dx == 0.0 and dy == 0.0 and dz == 0.0 then return end
    local moveLen = math.sqrt(dx * dx + dy * dy)
    if moveLen > 0.0001 then
        dx = dx / moveLen
        dy = dy / moveLen
    end

    local newX = MGSA_PLAYER_POS.x + dx * speed
    local newY = MGSA_PLAYER_POS.y + dy * speed
    MGSA_AIRBREAK_DATA.start_z = MGSA_AIRBREAK_DATA.start_z + dz

    setCharCoordinates(PLAYER_PED, newX, newY, MGSA_AIRBREAK_DATA.start_z)
end

return __MGSAAirBreak__