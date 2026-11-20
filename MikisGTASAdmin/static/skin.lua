
local __MGSASkin__ = {}

function __MGSASkin__.set(param)
    local skin = tonumber(param)

    if not skin or skin < 0 or skin > 311 or skin % 1 ~= 0 then
        sendWarningMessage("Koristi: /mgsa setskin [0-311]", -1)
        return
    end

    if isCharInAnyCar(PLAYER_PED) then
        sendErrorMessage("Izadji iz vozila prije promjene skina!", -1)
        return
    end

    if isCharDead(PLAYER_PED) then
        sendErrorMessage("Ne mozes mijenjati skin dok si mrtav!", -1)
        return
    end

    setPlayerModel(PLAYER_HANDLE, skin)

    sendSuccessMessage("Postavljen skin ID: " .. skin, -1)
end

return __MGSASkin__