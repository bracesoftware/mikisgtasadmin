
local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CVector'
shared.require 'v03dl.CPed'
shared.require 'v03dl.CObject'
shared.require 'v03dl.CVehicle'
shared.require 'v03dl.CAudio'
shared.require 'v03dl.CCamera'

shared.ffi.cdef[[
enum SCursorMode {
    CURSOR_NONE = 0,
    CURSOR_LOCKKEYS_NOCURSOR = 1,
    CURSOR_LOCKCAMANDCONTROL = 2,
    CURSOR_LOCKCAM = 3,
    CURSOR_LOCKCAM_NOCURSOR = 4,
};
typedef enum SCursorMode SCursorMode;

typedef struct CWeaponInfo CWeaponInfo;
typedef struct IDirect3DDevice9 IDirect3DDevice9;

typedef struct SCGame SCGame;

#pragma pack(push, 1)
struct SCGame {
    SCAudio* m_pAudio;
    SCCamera* m_pCamera;
    SCPed* m_pPlayerPed;

    struct {
        SCVector m_position;
        SCVector m_size;
        BOOL m_bEnabled;
        GTAREF m_handle;
    } m_checkpoint;

    struct {
        SCVector m_currentPosition;
        SCVector m_nextPosition;
        float m_fSize;
        char m_nType;
        BOOL m_bEnabled;
        GTAREF m_marker;
        GTAREF m_handle;
    } m_racingCheckpoint;

    int m_nCursorMode;
    unsigned int m_nInputEnableWaitFrames;
    BOOL m_bClockEnabled;
    int field_61;
    BOOL m_bHeadMove;
    int m_nFrameLimiter;
    char field_6d;
    bool m_aKeepLoadedVehicleModels[212];
};
#pragma pack(pop)
]]

shared.validate_size('struct SCGame', 0x142)

local function RefGame()
    return ffi.cast(
        'SCGame**',
        sampapi.GetAddress(0x2ACA3C)
    )
end

local function RefGameTextMessage()
    return ffi.cast(
        'char**',
        sampapi.GetAddress(0x18E1CC)
    )
end

local function ArrayUsedPlayerSlots()
    return ffi.cast(
        'BOOL*',
        sampapi.GetAddress(0x18E1D8)
    )
end

local CGame_constructor = ffi.cast(
    'void(__thiscall*)(SCGame*)',
    sampapi.GetAddress(0x9FDC0)
)

local function CGame_new()
    local obj = ffi.new('struct SCGame[1]')
    CGame_constructor(obj)
    return obj
end

local SCGame_mt = {
    GetPlayerPed = ffi.cast(
        'SCPed*(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0x1010)
    ),

    FindGroundZ = ffi.cast(
        'float(__thiscall*)(SCGame*, SCVector)',
        sampapi.GetAddress(0xA0240)
    ),

    SetCursorMode = ffi.cast(
        'void(__thiscall*)(SCGame*, int, BOOL)',
        sampapi.GetAddress(0xA0530)
    ),

    InitGame = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA06D0)
    ),

    StartGame = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0720)
    ),

    IsMenuVisible = ffi.cast(
        'BOOL(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0760)
    ),

    IsStarted = ffi.cast(
        'BOOL(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0770)
    ),

    RequestModel = ffi.cast(
        'void(__thiscall*)(SCGame*, int, int)',
        sampapi.GetAddress(0xA0780)
    ),

    LoadRequestedModels = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA07A0)
    ),

    IsModelAvailable = ffi.cast(
        'BOOL(__thiscall*)(SCGame*, int)',
        sampapi.GetAddress(0xA07B0)
    ),

    ReleaseModel = ffi.cast(
        'void(__thiscall*)(SCGame*, int, bool)',
        sampapi.GetAddress(0xA07E0)
    ),

    SetWorldTime = ffi.cast(
        'void(__thiscall*)(SCGame*, char, char)',
        sampapi.GetAddress(0xA08F0)
    ),

    GetWorldTime = ffi.cast(
        'void(__thiscall*)(SCGame*, char*, char*)',
        sampapi.GetAddress(0xA0920)
    ),

    LetTimeGo = ffi.cast(
        'void(__thiscall*)(SCGame*, bool)',
        sampapi.GetAddress(0xA0940)
    ),

    SetWorldWeather = ffi.cast(
        'void(__thiscall*)(SCGame*, char)',
        sampapi.GetAddress(0xA0980)
    ),

    SetFrameLimiter = ffi.cast(
        'void(__thiscall*)(SCGame*, int)',
        sampapi.GetAddress(0xA09F0)
    ),

    SetMaxStats = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0A20)
    ),

    DisableTrainTraffic = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0A50)
    ),

    RefreshRenderer = ffi.cast(
        'void(__thiscall*)(SCGame*, float, float)',
        sampapi.GetAddress(0xA0A60)
    ),

    RequestAnimation = ffi.cast(
        'void(__thiscall*)(SCGame*, const char*)',
        sampapi.GetAddress(0xA0A90)
    ),

    IsAnimationLoaded = ffi.cast(
        'BOOL(__thiscall*)(SCGame*, const char*)',
        sampapi.GetAddress(0xA0AB0)
    ),

    ReleaseAnimation = ffi.cast(
        'void(__thiscall*)(SCGame*, const char*)',
        sampapi.GetAddress(0xA0AD0)
    ),

    DisplayGameText = ffi.cast(
        'void(__thiscall*)(SCGame*, const char*, int, int)',
        sampapi.GetAddress(0xA0B20)
    ),

    DeleteRacingCheckpoint = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0B80)
    ),

    CreateMarker = ffi.cast(
        'GTAREF(__thiscall*)(SCGame*, int, SCVector, int, int)',
        sampapi.GetAddress(0xA0BB0)
    ),

    DeleteMarker = ffi.cast(
        'void(__thiscall*)(SCGame*, GTAREF)',
        sampapi.GetAddress(0xA0CE0)
    ),

    GetCurrentInterior = ffi.cast(
        'char(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0D00)
    ),

    UpdateFarClippingPlane = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0D20)
    ),

    IncreasePlayerMoney = ffi.cast(
        'void(__thiscall*)(SCGame*, int)',
        sampapi.GetAddress(0xA0D90)
    ),

    GetPlayerMoney = ffi.cast(
        'int(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0DB0)
    ),

    GetWeaponName = ffi.cast(
        'const char*(__thiscall*)(SCGame*, int)',
        sampapi.GetAddress(0xA0DC0)
    ),

    CreatePickup = ffi.cast(
        'void(__thiscall*)(SCGame*, int, int, SCVector, GTAREF*)',
        sampapi.GetAddress(0xA1010)
    ),

    CreateWeaponPickup = ffi.cast(
        'GTAREF(__thiscall*)(SCGame*, int, int, SCVector)',
        sampapi.GetAddress(0xA10F0)
    ),

    GetDevice = ffi.cast(
        'IDirect3DDevice9*(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1190)
    ),

    Restart = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA11D0)
    ),

    GetWeaponInfo = ffi.cast(
        'CWeaponInfo*(__thiscall*)(SCGame*, int, int)',
        sampapi.GetAddress(0xA1200)
    ),

    SetWorldGravity = ffi.cast(
        'void(__thiscall*)(SCGame*, float)',
        sampapi.GetAddress(0xA1220)
    ),

    SetWantedLevel = ffi.cast(
        'void(__thiscall*)(SCGame*, char)',
        sampapi.GetAddress(0xA1240)
    ),

    SetNumberOfIntroTextLinesThisFrame = ffi.cast(
        'void(__thiscall*)(SCGame*, unsigned short)',
        sampapi.GetAddress(0xA1250)
    ),

    DrawGangZone = ffi.cast(
        'void(__thiscall*)(SCGame*, float*, char)',
        sampapi.GetAddress(0xA1260)
    ),

    EnableZoneDisplaying = ffi.cast(
        'void(__thiscall*)(SCGame*, bool)',
        sampapi.GetAddress(0xA1340)
    ),

    EnableStuntBonus = ffi.cast(
        'void(__thiscall*)(SCGame*, bool)',
        sampapi.GetAddress(0xA1360)
    ),

    LoadScene = ffi.cast(
        'void(__thiscall*)(SCGame*, const char*)',
        sampapi.GetAddress(0xA13D0)
    ),

    GetUsedMemory = ffi.cast(
        'int(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA13F0)
    ),

    GetStreamingMemory = ffi.cast(
        'int(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1400)
    ),

    SetRequiredVehicleModels = ffi.cast(
        'void(__thiscall*)(SCGame*, unsigned char*)',
        sampapi.GetAddress(0xA1430)
    ),

    GetTimer = ffi.cast(
        'int(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1590)
    ),

    LoadAnimationsAndModels = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA16C0)
    ),

    LoadCollisionFile = ffi.cast(
        'void(__thiscall*)(SCGame*, const char*)',
        sampapi.GetAddress(0xA19A0)
    ),

    LoadCullZone = ffi.cast(
        'void(__thiscall*)(SCGame*, const char*)',
        sampapi.GetAddress(0xA19C0)
    ),

    UsingGamepad = ffi.cast(
        'BOOL(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA19E0)
    ),

    DisableAutoAiming = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA19F0)
    ),

    EnableHUD = ffi.cast(
        'void(__thiscall*)(SCGame*, BOOL)',
        sampapi.GetAddress(0xA1BD0)
    ),

    SetCheckpoint = ffi.cast(
        'void(__thiscall*)(SCGame*, SCVector*, SCVector*)',
        sampapi.GetAddress(0xA1C00)
    ),

    CreateRacingCheckpoint = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1CC0)
    ),

    ProcessCheckpoints = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1D40)
    ),

    ResetMoney = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1EE0)
    ),

    SetRacingCheckpoint = ffi.cast(
        'void(__thiscall*)(SCGame*, int, SCVector*, SCVector*, float)',
        sampapi.GetAddress(0xA1F20)
    ),

    EnableRadar = ffi.cast(
        'void(__thiscall*)(SCGame*, BOOL)',
        sampapi.GetAddress(0xA0B00)
    ),

    GetWindowHandle = ffi.cast(
        'void*(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0x2D40)
    ),

    GetAudio = ffi.cast(
        'SCAudio*(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0x2D50)
    ),

    GetCamera = ffi.cast(
        'SCCamera*(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0x2D60)
    ),

    DoesHeadMoves = ffi.cast(
        'BOOL(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0x2D70)
    ),

    EnableClock = ffi.cast(
        'void(__thiscall*)(SCGame*, bool)',
        sampapi.GetAddress(0xA1280)
    ),

    Sleep = ffi.cast(
        'void(__thiscall*)(SCGame*, int, int)',
        sampapi.GetAddress(0x9FED0)
    ),

    CreatePed = ffi.cast(
        'SCPed*(__thiscall*)(SCGame*, int, SCVector, float, int, int)',
        sampapi.GetAddress(0x9FF50)
    ),

    RemovePed = ffi.cast(
        'BOOL(__thiscall*)(SCGame*, SCPed*)',
        sampapi.GetAddress(0xA0050)
    ),

    CreateVehicle = ffi.cast(
        'SCVehicle*(__thiscall*)(SCGame*, int, SCVector, float, BOOL)',
        sampapi.GetAddress(0xA0090)
    ),

    CreateObject = ffi.cast(
        'SCObject*(__thiscall*)(SCGame*, int, SCVector, SCVector, float, char, char)',
        sampapi.GetAddress(0xA0170)
    ),

    ProcessInputEnabling = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA0410)
    ),

    ProcessFrameLimiter = ffi.cast(
        'void(__thiscall*)(SCGame*)',
        sampapi.GetAddress(0xA1A30)
    ),
}

mt.set_handler('struct SCGame', '__index', SCGame_mt)

return {
    RefGame = RefGame,
    new = CGame_new,
    RefGameTextMessage = RefGameTextMessage,
    ArrayUsedPlayerSlots = ArrayUsedPlayerSlots,
}
