local __MGSASprinthook__ = {}
local n = 0

function __MGSASprinthook__.toggle()
    MGSA_SPRINTHOOK = not MGSA_SPRINTHOOK
    sendInfoMessage("Promijenjen status sprinthook-a!")
    if MGSA_SPRINTHOOK then
        MGSAAltChat.send(
            {{
                text = "Brzo trcanje ",
                color = BIJELA
            },
            {
                text = "ukljuceno!",
                color = ZELENA
            }}
        )
    else
        MGSAAltChat.send(
            {{
                text = "Brzo trcanje ",
                color = BIJELA
            },
            {
                text = "iskljuceno!",
                color = ZELENA
            }}
        )
    end
end

function __MGSASprinthook__.load()
    MGSA_LOADED_MODULE({
        name = "Sprinthook",
        desc = "Pruza automatsko brzo trcanje pri cemu se ne mozete umoriti."
    })
end

function __MGSASprinthook__.loop()
    if not MGSA_SPRINTHOOK then
        setPlayerNeverGetsTired(PLAYER_HANDLE, false)
        return
    end

    setPlayerNeverGetsTired(PLAYER_HANDLE, true)

    if MGSA_SPRINTHOOK and isCharOnFoot(PLAYER_PED) then
        if isButtonPressed(PLAYER_HANDLE, 16) then
            local c = os.clock()
            if c >= n then
                setGameKeyState(16, 255)
                n = c + 0.04
            else
                setGameKeyState(16, 0)
            end
        end
    end
end

return __MGSASprinthook__