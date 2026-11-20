
local sampapi = require 'sampapi'
local ffi = require 'ffi'

local function getCommand(address)
    return ffi.cast('CMDPROC', sampapi.GetAddress(address))
end

local Default = getCommand(0x67F50)
local TestDeathWindow = getCommand(0x67F70)
local ToggleCameraTargetLabels = getCommand(0x68050)
local SetChatPageSize = getCommand(0x68060)
local SetChatFontSize = getCommand(0x680E0)
local DrawNameTagStatus = getCommand(0x68190)
local DrawChatTimestamps = getCommand(0x681A0)
local ToggleAudioStreamMessages = getCommand(0x68200)
local ToggleURLMessages = getCommand(0x68270)
local PrintMemory = getCommand(0x682F0)
local SetFrameLimiter = getCommand(0x68310)
local ToggleHeadMoves = getCommand(0x683A0)
local Quit = getCommand(0x68420)
local CmpStat = getCommand(0x68430)
local SavePosition = getCommand(0x68440)
local SavePositionOnly = getCommand(0x685C0)
local PrintCurrentInterior = getCommand(0x68A10)
local ToggleObjectsLight = getCommand(0x68A40)
local ToggleDebugLabels = getCommand(0x68A60)
local SendRconCommand = getCommand(0x68A70)

local Debug = {
    SetPlayerSkin = getCommand(0x68740),
    CreateVehicle = getCommand(0x687B0),
    EnableVehicleSelection = getCommand(0x688F0),
    SetWorldWeather = getCommand(0x68910),
    SetWorldTime = getCommand(0x68960),
}

local Setup = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0x68B50)
)

return {
    Default = Default,
    TestDeathWindow = TestDeathWindow,
    ToggleCameraTargetLabels = ToggleCameraTargetLabels,
    SetChatPageSize = SetChatPageSize,
    SetChatFontSize = SetChatFontSize,
    DrawNameTagStatus = DrawNameTagStatus,
    DrawChatTimestamps = DrawChatTimestamps,
    ToggleAudioStreamMessages = ToggleAudioStreamMessages,
    ToggleURLMessages = ToggleURLMessages,
    PrintMemory = PrintMemory,
    SetFrameLimiter = SetFrameLimiter,
    ToggleHeadMoves = ToggleHeadMoves,
    Quit = Quit,
    CmpStat = CmpStat,
    SavePosition = SavePosition,
    SavePositionOnly = SavePositionOnly,
    PrintCurrentInterior = PrintCurrentInterior,
    ToggleObjectsLight = ToggleObjectsLight,
    ToggleDebugLabels = ToggleDebugLabels,
    SendRconCommand = SendRconCommand,
    Debug = Debug,
    Setup = Setup,
}
