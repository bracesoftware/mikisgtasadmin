
local sampapi = require 'sampapi'
local shared = sampapi.shared

shared.ffi.cdef[[
typedef struct SControllerState SControllerState;

#pragma pack(push, 1)
struct SControllerState {
    short m_sLeftStickX;
    short m_sLeftStickY;

    union {
        struct {
            unsigned char m_bLeftShoulder1 : 1;
            unsigned char m_bShockButtonL : 1;
            unsigned char m_bButtonCircle : 1;
            unsigned char m_bButtonCross : 1;
            unsigned char m_bButtonTriangle : 1;
            unsigned char m_bButtonSquare : 1;
            unsigned char m_bRightShoulder2 : 1;
            unsigned char m_bRightShoulder1 : 1;

            unsigned char m_bLeftShoulder2 : 1;
            unsigned char m_bShockButtonR : 1;
            unsigned char m_bPedWalk : 1;
            unsigned char m_bRightStickDown : 1;
            unsigned char m_bRightStickUp : 1;
            unsigned char m_bRightStickRight : 1;
            unsigned char m_bRightStickLeft : 1;
        };

        short m_value;
    };
};
#pragma pack(pop)
]]

shared.validate_size('struct SControllerState', 0x6)

return {}
