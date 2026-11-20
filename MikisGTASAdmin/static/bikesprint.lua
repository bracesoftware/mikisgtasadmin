local __MGSAutoBikeSprint__ = {}

local MIKIGTASADMIN_CANSPRINT = true
local MIKIGTASADMIN_CANSPRINT_OLD = true
local ADDR_PLAYER_PED = 0xB6F5F0
local ADDR_PED_VEHICLE = 0x58C
local ADDR_VEHICLE_MODEL = 0x22
local BUTTON_SPRINT = MGSA_KEY_R
local bike = {[481] = true, [509] = true, [510] = true}

local function getVehicleModel()
    local success, pedPtr = pcall(readMemory, ADDR_PLAYER_PED, 4, false)
    if not success or pedPtr == 0 then return 0 end
    
    local successVeh, vehPtr = pcall(readMemory, pedPtr + ADDR_PED_VEHICLE, 4, false)
    if not successVeh or vehPtr == 0 then return 0 end
    
    local successModel, model = pcall(readMemory, vehPtr + ADDR_VEHICLE_MODEL, 2, false)
    if not successModel then return 0 end
    
    return model
end

local function isInVehicle()
    local success, pedPtr = pcall(readMemory, ADDR_PLAYER_PED, 4, false)
    if not success or pedPtr == 0 then return false end
    
    local successVeh, vehPtr = pcall(readMemory, pedPtr + ADDR_PED_VEHICLE, 4, false)
    if not successVeh then return false end
    
    return vehPtr ~= 0
end

function __MGSAutoBikeSprint__.load()
    MGSA_LOADED_MODULE({
        name = "Bike Tweaks",
        desc = "Omogucava razne hackove vezane za biciklo."
        ..'\n'..MGSA_TAB..MGSA_TAB.."- R za automatski sprint."
        ..'\n'..MGSA_TAB..MGSA_TAB.."- LALT za visoki skok/bike bunnyhop."
    })
end

local nextPressTime = 0
local isHoldingSprint = false

function __MGSAutoBikeSprint__.loop()
    MIKIGTASADMIN_CANSPRINT = not MGSA_API.isSampChatOpened() and not MGSA_API.isSampDialogOnScreen()

    if MIKIGTASADMIN_CANSPRINT ~= MIKIGTASADMIN_CANSPRINT_OLD then
        if MIKIGTASADMIN_CANSPRINT then
            MGSAAltChat.send(
                {{
                    text = "Automatsko sprintanje sa biciklom ",
                    color = BIJELA
                },
                {
                    text = "ukljuceno!",
                    color = ZELENA
                }}
            )
        else
            MGSAAltChat.send(
                {{
                    text = "Automatsko sprintanje sa biciklom ",
                    color = BIJELA
                },
                {
                    text = "iskljuceno!",
                    color = CRVENA
                }}
            )
        end
        MIKIGTASADMIN_CANSPRINT_OLD = MIKIGTASADMIN_CANSPRINT
    end

    if MIKIGTASADMIN_CANSPRINT and isKeyDown(BUTTON_SPRINT) then
        if isInVehicle() then
            local model = getVehicleModel()
            if bike[model] then
                local c = os.clock()
                if c >= nextPressTime then
                    if isHoldingSprint then
                        setGameKeyState(16, 0)
                        isHoldingSprint = false
                        nextPressTime = c + 0.05
                    else
                        setGameKeyState(16, 255)
                        isHoldingSprint = true
                        nextPressTime = c + 0.05
                    end
                end
                return
            end
        end
    end
    
    if isHoldingSprint then
        setGameKeyState(16, 0)
        isHoldingSprint = false
    end
end


-- SUPER BIKE CHARGE JUMP

function __MGSAutoBikeSprint__.bikeJump()
    if not MIKIGTASADMIN_CANSPRINT then return end

    local model = getVehicleModel()
    local onBike = isInVehicle() and bike[model]

    if not onBike then return end
    if not isKeyDown(MGSA_KEY_LALT) then return end

    local success, pedPtr = pcall(readMemory, ADDR_PLAYER_PED, 4, false)
    if not success or pedPtr == 0 then return end

    local successVeh, vehPtr = pcall(
        readMemory,
        pedPtr + ADDR_PED_VEHICLE,
        4,
        false
    )

    if not successVeh or vehPtr == 0 then return end

    writeMemory(vehPtr + 0x4c, 4, representFloatAsInt(0.3), false)
end

return __MGSAutoBikeSprint__