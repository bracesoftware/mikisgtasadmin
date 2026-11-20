
--[[
    Project: SAMP-API.lua
    Developers: LUCHARE, ARMOR

    SA-MP 0.3.DL-1
    Based on BlastHack SAMP-API.
]]

local shared = require 'sampapi.shared'
local ffi = shared.ffi

ffi.cdef[[
typedef struct SAnimation SAnimation;

#pragma pack(push, 1)
struct SAnimation {
    union {
        struct {
            unsigned short m_nId;
            unsigned char m_nFramedelta;
            unsigned char m_nLoopA : 1;
            unsigned char m_nLockX : 1;
            unsigned char m_nLockY : 1;
            unsigned char m_nLockF : 1;
            unsigned char m_nTime : 2;
            unsigned char : 2;
        };
        int m_value;
    };
};
#pragma pack(pop)
]]

shared.validate_size('struct SAnimation', 0x4)

return {}
