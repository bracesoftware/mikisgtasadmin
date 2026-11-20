
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CMatrix'
shared.require 'CVector'
shared.require 'v03dl.CPed'
shared.require 'v03dl.CVehicle'
shared.require 'v03dl.Animation'
shared.require 'v03dl.Synchronization'

shared.ffi.cdef[[
enum SPlayerState {
    PLAYER_STATE_NONE = 0,
    PLAYER_STATE_ONFOOT = 17,
    PLAYER_STATE_DRIVER = 19,
    PLAYER_STATE_PASSENGER = 18,
    PLAYER_STATE_WASTED = 32,
    PLAYER_STATE_SPAWNED = 33,
};

enum SUpdateType {
    UPDATE_TYPE_NONE = 0,
    UPDATE_TYPE_ONFOOT = 16,
    UPDATE_TYPE_INCAR = 17,
    UPDATE_TYPE_PASSENGER = 18,
};

enum SPlayerStatus {
    PLAYER_STATUS_TIMEOUT = 2,
};

typedef struct SCRemotePlayer SCRemotePlayer;

#pragma pack(push, 1)
struct SCRemotePlayer {
    ID m_nId;
    ID m_nVehicleId;
    SCPed* m_pPed;
    SCVehicle* m_pVehicle;

    int field_14;
    BOOL m_bDrawLabels;
    BOOL m_bHasJetpack;

    unsigned char m_nSpecialAction;
    unsigned char m_nTeam;
    unsigned char m_nState;
    unsigned char m_nSeatId;

    int field_1C;
    BOOL m_bPassengerDriveBy;

    SPassengerData m_passengerData;
    SOnfootData m_onfootData;
    SIncarData m_incarData;
    STrailerData m_trailerData;
    SAimData m_aimData;

    int pad_114[3];

    SCVector m_onfootTargetPosition;
    SCVector m_onfootTargetSpeed;
    SCVector m_incarTargetPosition;
    SCVector m_incarTargetSpeed;

    unsigned char pad_150[64];

    SCVector m_positionDifference;

    struct {
        float real;
        SCVector imag;
    } m_incarTargetRotation;

    float m_fReportedArmour;
    float m_fReportedHealth;

    int pad_1B4[3];

    SAnimation m_animation;
    unsigned char m_nUpdateType;

    TICK m_lastUpdate;
    TICK m_lastTimestamp;

    BOOL m_bPerformingCustomAnimation;
    int m_nStatus;

    struct {
        SCVector m_direction;
        TICK m_lastUpdate;
        TICK m_lastLook;
    } m_head;

    BOOL m_bMarkerState;

    struct {
        int x;
        int y;
        int z;
    } m_markerPosition;

    GTAREF m_marker;
};
#pragma pack(pop)
]]

local CRemotePlayer_constructor = ffi.cast(
    'void(__thiscall*)(SCRemotePlayer*)',
    sampapi.GetAddress(0x16250)
)

local CRemotePlayer_destructor = ffi.cast(
    'void(__thiscall*)(SCRemotePlayer*)',
    sampapi.GetAddress(0x162C0)
)

local function CRemotePlayer_new()
    local obj = ffi.gc(
        ffi.new('struct SCRemotePlayer[1]'),
        CRemotePlayer_destructor
    )
    CRemotePlayer_constructor(obj)
    return obj
end

local SCRemotePlayer_mt = {
    ProcessHead = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14240)
    ),

    SetMarkerState = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, BOOL)',
        sampapi.GetAddress(0x14390)
    ),

    SetMarkerPosition = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, int, int, int)',
        sampapi.GetAddress(0x143D0)
    ),

    SurfingOnVehicle = ffi.cast(
        'BOOL(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14470)
    ),

    SurfingOnObject = ffi.cast(
        'BOOL(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x144A0)
    ),

    ProcessSurfing = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x144D0)
    ),

    OnEnterVehicle = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14660)
    ),

    OnExitVehicle = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14730)
    ),

    ProcessSpecialAction = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14780)
    ),

    UpdateOnfootSpeedAndPosition = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x149F0)
    ),

    UpdateOnfootRotation = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14D80)
    ),

    SetOnfootTargetSpeedAndPosition = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SCVector*, SCVector*)',
        sampapi.GetAddress(0x14E50)
    ),

    UpdateIncarSpeedAndPosition = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x14EC0)
    ),

    UpdateIncarRotation = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x151C0)
    ),

    SetIncarTargetSpeedAndPosition = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SCMatrix*, SCVector*, SCVector*)',
        sampapi.GetAddress(0x15330)
    ),

    UpdateTrain = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SCMatrix*, SCVector*, float)',
        sampapi.GetAddress(0x153A0)
    ),

    UpdateAim = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SAimData*)',
        sampapi.GetAddress(0x154A0)
    ),

    UpdateUnoccupied = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SUnoccupiedData*)',
        sampapi.GetAddress(0x15600)
    ),

    UpdateTrailer = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, STrailerData*)',
        sampapi.GetAddress(0x15950)
    ),

    ResetData = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x15C60)
    ),

    GetDistanceToPlayer = ffi.cast(
        'float(__thiscall*)(SCRemotePlayer*, SCRemotePlayer*)',
        sampapi.GetAddress(0x15D50)
    ),

    GetDistanceToLocalPlayer = ffi.cast(
        'float(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x15DD0)
    ),

    SetColor = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, D3DCOLOR)',
        sampapi.GetAddress(0x15E00)
    ),

    GetColorAsRGBA = ffi.cast(
        'D3DCOLOR(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x15E20)
    ),

    GetColorAsARGB = ffi.cast(
        'D3DCOLOR(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x15E30)
    ),

    EnterVehicle = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, ID, BOOL)',
        sampapi.GetAddress(0x15E50)
    ),

    ExitVehicle = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x15EE0)
    ),

    ChangeState = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, char, char)',
        sampapi.GetAddress(0x15F10)
    ),

    GetStatus = ffi.cast(
        'int(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x15FD0)
    ),

    UpdateBullet = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SBulletData*)',
        sampapi.GetAddress(0x16010)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x16310)
    ),

    Spawn = ffi.cast(
        'BOOL(__thiscall*)(SCRemotePlayer*, int, int, int, SCVector*, float, D3DCOLOR, char)',
        sampapi.GetAddress(0x16C50)
    ),

    UpdateOnfoot = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SOnfootData*, TICK)',
        sampapi.GetAddress(0x16DA0)
    ),

    UpdateIncar = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SIncarData*, TICK)',
        sampapi.GetAddress(0x16E70)
    ),

    UpdatePassenger = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, SPassengerData*, TICK)',
        sampapi.GetAddress(0x16F60)
    ),

    Remove = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x17040)
    ),

    Kill = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x17080)
    ),

    Chat = ffi.cast(
        'void(__thiscall*)(SCRemotePlayer*, const char*)',
        sampapi.GetAddress(0x17120)
    ),

    DoesExist = ffi.cast(
        'BOOL(__thiscall*)(SCRemotePlayer*)',
        sampapi.GetAddress(0x1080)
    ),
}

mt.set_handler('struct SCRemotePlayer', '__index', SCRemotePlayer_mt)

return {
    new = CRemotePlayer_new,
}
