
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1

    AimStuff
    Based on BlastHack SAMP-API C++ implementation.
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = shared.ffi

shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SAim SAim;

#pragma pack(push, 1)
struct SAim {
    SCVector front;
    SCVector source;
    SCVector sourceBeforeLookBehind;
    SCVector up;
};
#pragma pack(pop)
]]

shared.validate_size('struct SAim', 0x30)

-- Memory references

local function RefLocalPlayerCameraExtZoom()
    return ffi.cast('float*', sampapi.GetAddress(0x181E60))[0]
end

local function RefLocalPlayerAspectRatio()
    return ffi.cast('float*', sampapi.GetAddress(0x184A18))[0]
end

local function RefInternalCameraExtZoom()
    return ffi.cast('float**', sampapi.GetAddress(0x1419BC))[0]
end

local function RefInternalAspectRatio()
    return ffi.cast('float**', sampapi.GetAddress(0x1419B8))[0]
end

local function ArrayCameraExtZoom()
    return ffi.cast('float*', sampapi.GetAddress(0x181F40))
end

local function ArrayAspectRatio()
    return ffi.cast('float*', sampapi.GetAddress(0x184A48))
end

local function ArrayCameraMode()
    return ffi.cast('char*', sampapi.GetAddress(0x181E68))
end

local function RefInternalCameraMode()
    return ffi.cast('char**', sampapi.GetAddress(0x15195C))[0]
end

local function RefLocalPlayerAim()
    return ffi.cast('SAim*', sampapi.GetAddress(0x182288))
end

local function ArrayPlayerAim()
    return ffi.cast('SAim*', sampapi.GetAddress(0x1822B8))
end

local function RefInternalAim()
    return ffi.cast('SAim**', sampapi.GetAddress(0x1419B0))[0]
end

-- Functions

local UpdateCameraExtZoomAndAspectRatio =
    ffi.cast('void(__stdcall*)()', sampapi.GetAddress(0x9C240))

local ApplyCameraExtZoomAndAspectRatio =
    ffi.cast('void(__stdcall*)()', sampapi.GetAddress(0x9C260))

local SetCameraExtZoomAndAspectRatio =
    ffi.cast('void(__stdcall*)(NUMBER, float, float)', sampapi.GetAddress(0x9C280))

local GetAspectRatio =
    ffi.cast('float(__stdcall*)()', sampapi.GetAddress(0x9C2A0))

local GetCameraExtZoom =
    ffi.cast('float(__stdcall*)()', sampapi.GetAddress(0x9C2B0))

local ApplyCameraExtZoomAndAspectRatioForPlayer =
    ffi.cast('void(__stdcall*)(NUMBER)', sampapi.GetAddress(0x9C2D0))

local SetCameraMode =
    ffi.cast('void(__stdcall*)(char, NUMBER)', sampapi.GetAddress(0x9C310))

local GetCameraModeForPlayer =
    ffi.cast('char(__stdcall*)(NUMBER)', sampapi.GetAddress(0x9C330))

local GetCameraMode =
    ffi.cast('char(__stdcall*)()', sampapi.GetAddress(0x9C340))

local Initialize =
    ffi.cast('void(__stdcall*)()', sampapi.GetAddress(0x9C350))

local UpdateAim =
    ffi.cast('void(__stdcall*)()', sampapi.GetAddress(0x9C3C0))

local ApplyAim =
    ffi.cast('void(__stdcall*)()', sampapi.GetAddress(0x9C3E0))

local GetAim =
    ffi.cast('SAim*(__stdcall*)()', sampapi.GetAddress(0x9C400))

local SetAim =
    ffi.cast('void(__stdcall*)(int, const SAim*)', sampapi.GetAddress(0x9C410))

local ApplyAimForPlayer =
    ffi.cast('void(__stdcall*)(int)', sampapi.GetAddress(0x9C440))

local GetAimForPlayer =
    ffi.cast('SAim*(__stdcall*)(int)', sampapi.GetAddress(0x9C470))

return {
    RefLocalPlayerCameraExtZoom = RefLocalPlayerCameraExtZoom,
    RefLocalPlayerAspectRatio = RefLocalPlayerAspectRatio,
    RefInternalCameraExtZoom = RefInternalCameraExtZoom,
    RefInternalAspectRatio = RefInternalAspectRatio,

    ArrayCameraExtZoom = ArrayCameraExtZoom,
    ArrayAspectRatio = ArrayAspectRatio,
    ArrayCameraMode = ArrayCameraMode,

    RefInternalCameraMode = RefInternalCameraMode,

    RefLocalPlayerAim = RefLocalPlayerAim,
    ArrayPlayerAim = ArrayPlayerAim,
    RefInternalAim = RefInternalAim,

    UpdateCameraExtZoomAndAspectRatio = UpdateCameraExtZoomAndAspectRatio,
    ApplyCameraExtZoomAndAspectRatio = ApplyCameraExtZoomAndAspectRatio,
    SetCameraExtZoomAndAspectRatio = SetCameraExtZoomAndAspectRatio,

    GetAspectRatio = GetAspectRatio,
    GetCameraExtZoom = GetCameraExtZoom,

    ApplyCameraExtZoomAndAspectRatioForPlayer = ApplyCameraExtZoomAndAspectRatioForPlayer,

    SetCameraMode = SetCameraMode,
    GetCameraModeForPlayer = GetCameraModeForPlayer,
    GetCameraMode = GetCameraMode,

    Initialize = Initialize,

    UpdateAim = UpdateAim,
    ApplyAim = ApplyAim,
    GetAim = GetAim,
    SetAim = SetAim,

    ApplyAimForPlayer = ApplyAimForPlayer,
    GetAimForPlayer = GetAimForPlayer
}
