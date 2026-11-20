
local __MGSASpecHack__ = {}

local MGSA_SPECA = false
local MGSA_SPEC_TARGET = nil

function __MGSASpecHack__.load()
    MGSA_LOADED_MODULE({
        name = "Spec-Hack",
        desc = "Omogucava specanje strimovanih igraca i kada niste admin."
    })
end

local function stopSpec()
    if not MGSA_SPECA then
        sendErrorMessage("Vi niste u specu.")
        return
    end

    restoreCameraJumpcut()

    MGSA_SPECA = false
    MGSA_SPEC_TARGET = nil

    sendWarningMessage("Izasli ste iz speca.")
end

local function startSpec(targetId)
    if not MGSA_API.sampIsPlayerConnected(targetId) then
        sendErrorMessage("Taj igrac nije povezan na server!")
        return
    end

    local result, ped = MGSA_API.sampGetCharHandleBySampPlayerId(targetId)

    if not result or not doesCharExist(ped) then
        sendErrorMessage("Igrac nije u vasoj stream zoni!")
        return
    end

    if isCharInAnyCar(ped) then
        local veh = storeCarCharIsInNoSave(ped)

        cameraSetLerpFov(70.0, 70.0, 1000, true)

        attachCameraToVehicle(
            veh,
            0.0, -5.0, 2.0,
            0.0, 0.0, 0.0,
            0.0, 2
        )
    else
        attachCameraToChar(
            ped,
            0.0, -3.0, 1.0,
            0.0, 0.0, 0.0,
            0.0, 2
        )
    end

    MGSA_SPECA = true
    MGSA_SPEC_TARGET = targetId

    sendInfoMessage("Poceli ste sa specom igraca " .. targetId .. "!")
end

function __MGSASpecHack__.spec(arg)
    if not arg or arg == "" then
        sendWarningMessage("Koristi: /mgsa spec [ID igraca]")
        return
    end

    local targetId = tonumber(arg)

    if not targetId or targetId < 0 or targetId > 1004 or targetId % 1 ~= 0 then
        sendErrorMessage("Unijeli ste nevazeci ID.")
        return
    end

    startSpec(targetId)
end

function __MGSASpecHack__.specoff()
    stopSpec()
end

function __MGSASpecHack__.update()
    if not MGSA_SPECA or not MGSA_SPEC_TARGET then
        return
    end

    if not MGSA_API.sampIsPlayerConnected(MGSA_SPEC_TARGET) then
        stopSpec()
        sendWarningMessage("Igrac kojeg ste pratili je napustio server.")
        return
    end

    local result, ped = MGSA_API.sampGetCharHandleBySampPlayerId(MGSA_SPEC_TARGET)

    if not result or not doesCharExist(ped) then
        return
    end

    if isCharInAnyCar(ped) then
        local veh = storeCarCharIsInNoSave(ped)

        attachCameraToVehicle(
            veh,
            0.0, -5.0, 2.0,
            0.0, 0.0, 0.0,
            0.0, 2
        )
    else
        attachCameraToChar(
            ped,
            0.0, -3.0, 1.0,
            0.0, 0.0, 0.0,
            0.0, 2
        )
    end
end

return __MGSASpecHack__
