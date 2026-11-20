
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CVector'
shared.require 'v03dl.CPlayerPool'
shared.require 'v03dl.CVehiclePool'
shared.require 'v03dl.CPickupPool'
shared.require 'v03dl.CGangZonePool'
shared.require 'v03dl.CTextDrawPool'
shared.require 'v03dl.CMenuPool'
shared.require 'v03dl.CObjectPool'
shared.require 'v03dl.CActorPool'
shared.require 'v03dl.CLabelPool'

shared.ffi.cdef[[
enum SMarkersMode {
    MARKERS_MODE_OFF = 0,
    MARKERS_MODE_GLOBAL = 1,
    MARKERS_MODE_STREAMED = 2,
};
typedef enum SMarkersMode SMarkersMode;

enum SGameMode {
    GAME_MODE_WAITCONNECT = 0x1,
    GAME_MODE_CONNECTING = 0x2,
    GAME_MODE_CONNECTED = 0x5,
    GAME_MODE_WAITJOIN = 0x6,
    GAME_MODE_RESTARTING = 0xB,
};
typedef enum SGameMode SGameMode;

enum {
    NETMODE_STATS_UPDATE_DELAY = 1000,
    NETMODE_INCAR_SENDRATE = 30,
    NETMODE_ONFOOT_SENDRATE = 30,
    NETMODE_FIRING_SENDRATE = 30,
    LANMODE_INCAR_SENDRATE = 15,
    LANMODE_ONFOOT_SENDRATE = 15,
    NETMODE_SEND_MULTIPLIER = 2,
    NETMODE_AIM_UPDATE_DELAY = 500,
    NETMODE_HEAD_UPDATE_DELAY = 1000,
    NETMODE_TARGET_UPDATE_DELAY = 100,
    NETMODE_PLAYERS_UPDATE_DELAY = 3000,
};

struct Packet;
struct RakClientInterface;

typedef struct SPools SPools;
#pragma pack(push, 1)
struct SPools {
    SCMenuPool* m_pMenu;
    SCActorPool* m_pActor;
    SCPlayerPool* m_pPlayer;
    SCVehiclePool* m_pVehicle;
    SCPickupPool* m_pPickup;
    SCObjectPool* m_pObject;
    SCGangZonePool* m_pGangZone;
    SCLabelPool* m_pLabel;
    SCTextDrawPool* m_pTextDraw;
};
#pragma pack(pop)

typedef struct SNetSettings SNetSettings;
#pragma pack(push, 1)
struct SNetSettings {
    bool m_bUseCJWalk;
    unsigned int m_nDeadDropsMoney;
    float m_fWorldBoundaries[4];
    bool m_bAllowWeapons;
    float m_fGravity;
    bool m_bEnterExit;
    BOOL m_bVehicleFriendlyFire;
    bool m_bHoldTime;
    bool m_bInstagib;
    bool m_bZoneNames;
    bool m_bFriendlyFire;
    BOOL m_bClassesAvailable;
    float m_fNameTagsDrawDist;
    bool m_bManualVehicleEngineAndLight;
    unsigned char m_nWorldTimeHour;
    unsigned char m_nWorldTimeMinute;
    unsigned char m_nWeather;
    bool m_bNoNametagsBehindWalls;
    int m_nPlayerMarkersMode;
    float m_fChatRadius;
    bool m_bNameTags;
    bool m_bLtdChatRadius;
};
#pragma pack(pop)

typedef struct SCNetGame SCNetGame;
#pragma pack(push, 1)
struct SCNetGame {
    char pad_0[44];
    struct RakClientInterface* m_pRakClient;
    char m_szHostAddress[257];
    char m_szHostname[257];
    bool m_bDisableCollision;
    bool m_bUpdateCameraTarget;
    bool m_bNametagStatus;
    int m_nPort;
    BOOL m_bLanMode;
    GTAREF m_aMapIcons[100];
    int m_nGameState;
    TICK m_lastConnectAttempt;
    SNetSettings* m_pSettings;
    char pad_2[5];
    SPools* m_pPools;
};
#pragma pack(pop)
]]

shared.validate_size('struct SPools', 0x24)
shared.validate_size('struct SNetSettings', 0x3A)

local function RefNetGame()
    return ffi.cast('SCNetGame**', sampapi.GetAddress(0x2ACA24))
end

local function RefLastPlayersUpdateRequest()
    return ffi.cast('TICK*', sampapi.GetAddress(0x156B30))
end

local CNetGame_constructor = ffi.cast(
    'void(__thiscall*)(SCNetGame*, const char*, int, const char*, const char*)',
    sampapi.GetAddress(0xB610)
)

local CNetGame_destructor = ffi.cast(
    'void(__thiscall*)(SCNetGame*)',
    sampapi.GetAddress(0x9570)
)

local function CNetGame_new(...)
    local obj = ffi.gc(
        ffi.new('struct SCNetGame[1]'),
        CNetGame_destructor
    )

    CNetGame_constructor(obj, ...)
    return obj
end

local SCNetGame_mt = {
    GetPickupPool = ffi.cast(
        'SCPickupPool*(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x81D0)
    ),

    GetMenuPool = ffi.cast(
        'SCMenuPool*(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x81E0)
    ),

    SetState = ffi.cast(
        'void(__thiscall*)(SCNetGame*, int)',
        sampapi.GetAddress(0x81F0)
    ),

    InitializePools = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8230)
    ),

    InitialNotification = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8450)
    ),

    InitializeGameLogic = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x85E0)
    ),

    Connect = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8630)
    ),

    SpawnScreen = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x86A0)
    ),

    Packet_RSAPublicKeyMismatch = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8A40)
    ),

    Packet_ConnectionBanned = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8A60)
    ),

    Packet_ConnectionRequestAcepted = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8A80)
    ),

    Packet_NoFreeIncomingConnections = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8AA0)
    ),

    Packet_DisconnectionNotification = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8AD0)
    ),

    Packet_InvalidPassword = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8B10)
    ),

    Packet_ConnectionAttemptFailed = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x8B50)
    ),

    UpdatePlayers = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8C00)
    ),

    DeleteMarker = ffi.cast(
        'void(__thiscall*)(SCNetGame*, NUMBER)',
        sampapi.GetAddress(0x8CA0)
    ),

    ResetPlayerPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8CD0)
    ),

    ResetVehiclePool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8D70)
    ),

    ResetTextDrawPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8E10)
    ),

    ResetObjectPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8EB0)
    ),

    ResetGangZonePool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8F50)
    ),

    ResetPickupPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8FF0)
    ),

    ResetMenuPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x9050)
    ),

    ResetLabelPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x90E0)
    ),

    ResetActorPool = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x9180)
    ),

    Packet_UnoccupiedSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9730)
    ),

    Packet_BulletSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9830)
    ),

    Packet_AimSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9930)
    ),

    Packet_PassengerSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9A20)
    ),

    Packet_TrailerSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9B10)
    ),

    Packet_MarkersSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9C00)
    ),

    Packet_AuthKey = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0x9DF0)
    ),

    ResetMarkers = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x9FB0)
    ),

    CreateMarker = ffi.cast(
        'void(__thiscall*)(SCNetGame*, NUMBER, SCVector, char, int, int)',
        sampapi.GetAddress(0x9FF0)
    ),

    ResetPools = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0xA1E0)
    ),

    ShutdownForRestart = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0xA230)
    ),

    Packet_PlayerSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0xA420)
    ),

    Packet_VehicleSync = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0xA6F0)
    ),

    Packet_ConnectionLost = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0xA9D0)
    ),

    Packet_ConnectionSucceeded = ffi.cast(
        'void(__thiscall*)(SCNetGame*, struct Packet*)',
        sampapi.GetAddress(0xAA60)
    ),

    UpdateNetwork = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0xAF40)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0xB290)
    ),

    ProcessGameStuff = ffi.cast(
        'void(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x8810)
    ),

    GetPlayerPool = ffi.cast(
        'SCPlayerPool*(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x1170)
    ),

    GetObjectPool = ffi.cast(
        'SCObjectPool*(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x2E40)
    ),

    GetActorPool = ffi.cast(
        'SCActorPool*(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x2E50)
    ),

    GetState = ffi.cast(
        'int(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x2E60)
    ),

    LanMode = ffi.cast(
        'BOOL(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x2E70)
    ),

    GetVehiclePool = ffi.cast(
        'SCVehiclePool*(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x1180)
    ),

    GetRakClient = function(self)
        return self.m_pRakClient
    end,

    GetCounter = ffi.cast(
        'long long(__thiscall*)(SCNetGame*)',
        sampapi.GetAddress(0x85D0)
    ),
}

mt.set_handler('struct SCNetGame', '__index', SCNetGame_mt)

return {
    RefNetGame = RefNetGame,
    RefLastPlayersUpdateRequest = RefLastPlayersUpdateRequest,
    new = CNetGame_new,
}
