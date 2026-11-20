
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.require 'CVector'
shared.require 'v03dl.Animation'
shared.require 'v03dl.ControllerState'

ffi.cdef[[
typedef struct SOnfootData SOnfootData;
#pragma pack(push, 1)
struct SOnfootData {
    SControllerState m_controllerState;
    SCVector m_position;
    float m_fQuaternion[4];
    unsigned char m_nHealth;
    unsigned char m_nArmor;
    unsigned char m_nCurrentWeapon;
    unsigned char m_nSpecialAction;
    SCVector m_speed;
    SCVector m_surfingOffset;
    ID m_nSurfingVehicleId;
    SAnimation m_animation;
};
#pragma pack(pop)

typedef struct SIncarData SIncarData;
#pragma pack(push, 1)
struct SIncarData {
    ID m_nVehicle;
    SControllerState m_controllerState;
    float m_fQuaternion[4];
    SCVector m_position;
    SCVector m_speed;
    float m_fHealth;
    unsigned char m_nDriverHealth;
    unsigned char m_nDriverArmor;
    unsigned char m_nCurrentWeapon;
    bool m_bSirenEnabled;
    bool m_bLandingGear;
    ID m_nTrailerId;
    union {
        unsigned short m_aHydraThrustAngle[2];
        float m_fTrainSpeed;
    };
};
#pragma pack(pop)

enum SWeaponState {
    WS_NO_BULLETS = 0,
    WS_LAST_BULLET = 1,
    WS_MORE_BULLETS = 2,
    WS_RELOADING = 3
};

typedef struct SAimData SAimData;
#pragma pack(push, 1)
struct SAimData {
    unsigned char m_nCameraMode;
    SCVector m_aimf1;
    SCVector m_aimPos;
    float m_fAimZ;
    unsigned char m_nCameraExtZoom : 6;
    unsigned char m_nWeaponState : 2;
    char m_nAspectRatio;
};
#pragma pack(pop)

typedef struct STrailerData STrailerData;
#pragma pack(push, 1)
struct STrailerData {
    ID m_nId;
    SCVector m_position;
    float m_fQuaternion[4];
    SCVector m_speed;
    SCVector m_turnSpeed;
};
#pragma pack(pop)

typedef struct SPassengerData SPassengerData;
#pragma pack(push, 1)
struct SPassengerData {
    ID m_nVehicleId;
    unsigned char m_nSeatId;
    unsigned char m_nCurrentWeapon;
    unsigned char m_nHealth;
    unsigned char m_nArmor;
    SControllerState m_controllerState;
    SCVector m_position;
};
#pragma pack(pop)

typedef struct SUnoccupiedData SUnoccupiedData;
#pragma pack(push, 1)
struct SUnoccupiedData {
    ID m_nVehicleId;
    unsigned char m_nSeatId;
    SCVector m_roll;
    SCVector m_direction;
    SCVector m_position;
    SCVector m_speed;
    SCVector m_turnSpeed;
    float m_fHealth;
};
#pragma pack(pop)

typedef struct SBulletData SBulletData;
#pragma pack(push, 1)
struct SBulletData {
    unsigned char m_nTargetType;
    ID m_nTargetId;
    SCVector m_origin;
    SCVector m_target;
    SCVector m_center;
    unsigned char m_nWeapon;
};
#pragma pack(pop)

typedef struct SSpectatorData SSpectatorData;
#pragma pack(push, 1)
struct SSpectatorData {
    SControllerState m_controllerState;
    SCVector m_position;
};
#pragma pack(pop)

typedef struct SStatsData SStatsData;
#pragma pack(push, 1)
struct SStatsData {
    int m_nMoney;
    int m_nDrunkLevel;
};
#pragma pack(pop)
]]

shared.validate_size('SOnfootData', 0x44)
shared.validate_size('SIncarData', 0x3F)
shared.validate_size('SAimData', 0x1F)
shared.validate_size('STrailerData', 0x36)
shared.validate_size('SPassengerData', 0x18)
shared.validate_size('SUnoccupiedData', 0x43)
shared.validate_size('SBulletData', 0x28)
shared.validate_size('SSpectatorData', 0x12)
shared.validate_size('SStatsData', 0x08)

local function CompressAspectRatio(value)
    return ffi.cast('int8_t', math.floor(value * 255))
end

local function DecompressAspectRatio(value)
    return tonumber(value) / 255
end

local bit = require("bit")

local function CompressCameraExtZoom(value)
    return bit.band(math.floor(value * 63), 63)
end

local function DecompressCameraExtZoom(value)
    return bit.band(value, 63) / 63
end

return {
    CompressAspectRatio = CompressAspectRatio,
    DecompressAspectRatio = DecompressAspectRatio,
    CompressCameraExtZoom = CompressCameraExtZoom,
    DecompressCameraExtZoom = DecompressCameraExtZoom,
}
