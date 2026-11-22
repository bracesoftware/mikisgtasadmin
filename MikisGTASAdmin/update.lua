function MGSA_SAMPMSG(text)
    local chatRX = MGSA_CChat.RefChat
    local chatDL = chatRX[0]
    print("MGSA_SAMPMSG: "..text)
    text = "[Miki's GTASAdmin]: "..text
    pcall(function (t)
        chatRX:AddEntry(8, t, "", 0xFFFFFFFF,0xFFFFFFFF)
    end, text)
    pcall(function (t)
        chatDL:AddEntry(8, t, "", 0xFFFFFFFF,0xFFFFFFFF)
    end, text)
end

function MGSA_Update(githubinf,roooooot,downfunc)
    createDirectory(roooooot)
    local ok
    local result

    print("[MGSA] PROVJERAVAM AZURIRANJA...")
    MGSA_SAMPMSG("Provjeravam azuriranja...")

    local VERSION_NOW = 0
    ok, result = pcall(dofile, roooooot .. githubinf.VERSION)
    if not ok or type(result) ~= "string" then
        VERSION_NOW = -1
    else VERSION_NOW = result end

    print("Trenutna verzija: v"..VERSION_NOW)

    local VERSION_ON_SERVER = 0
    print("SKIDAM INFORMACIJE O NAJNOVIJOJ VERZIJI")
    MGSA_SAMPMSG("Skidam informacije o novom azuriranju!")
    local ver = downfunc(
        githubinf.BASE_URL.."MikisGTASAdmin/".. githubinf.VERSION,
        roooooot .. githubinf.VERSION
    )

    if not ver then
        MGSA_SAMPMSG("Nije moguce preuzeti informacije o verziji!")
        return false
    end

    ok, result = pcall(dofile, roooooot .. githubinf.VERSION)
    if not ok or type(result) ~= "string" then
        VERSION_ON_SERVER = -1
    else VERSION_ON_SERVER = result end

    if VERSION_ON_SERVER == VERSION_NOW then
        MGSA_SAMPMSG("Nema novih azuriranja!")
        return true
    end

    MGSA_SAMPMSG("Novi update: " .. VERSION_ON_SERVER)
    MGSA_SAMPMSG("Pokrecem azuriranje...")

    MGSA_SAMPMSG("Skidanje manifesta...")
    local manifest = downfunc(
        githubinf.BASE_URL.."MikisGTASAdmin/"..githubinf.MANIFEST,
        roooooot .. githubinf.MANIFEST
    )

    if not manifest then
        MGSA_SAMPMSG("Nije moguce preuzeti manifest!")
        return false
    end

    ok, result = pcall(dofile, roooooot .. githubinf.MANIFEST)

    if not ok or type(result) ~= "table" then
        MGSA_SAMPMSG("Nije moguce preuzeti azuriranje: manifest ne postoji!")
        return false
    end

    MGSA_FILES = result

    for _, file in ipairs(MGSA_FILES) do

        local rrr = file:gsub(
            "^MikisGTASAdmin/", ""
        )

        local dd = rrr:match("^(.*)/[^/]+$")

        if dd then
            local cc = roooooot

            for folder in dd:gmatch("[^/]+") do
                cc = cc .. folder .. "\\"
                createDirectory(cc)
            end
        end

        local d = roooooot ..
            rrr:gsub("/", "\\")

        local tt = d .. ".tmp"

        MGSA_SAMPMSG("Skidanje: " .. rrr)


        if not downfunc(
            githubinf.BASE_URL .. file,
            tt
        ) then
            os.remove(tt)

            MGSA_SAMPMSG("Greska: " .. rrr)
            return false
        end

        local check = io.open(tt, "rb")

        if not check then
            MGSA_SAMPMSG("Fajl nije pronadjen: " .. tt)
            return false
        end

        local size = check:seek("end")
        check:close()

        if not size or size == 0 then
            os.remove(tt)

            MGSA_SAMPMSG("Prazan fajl: " .. rrr)
            return false
        end

        os.remove(d)
        local rr, ee = os.rename(tt,d)

        if not rr then
            print("[MGSA] RENAME ERROR: " .. tostring(ee))
            print("[MGSA] TEMP: " .. tt)
            print("[MGSA] DEST: " .. d)
            MGSA_SAMPMSG("Greska: "..tostring(ee)..'->'..tt..'->'..d)
            return false
        end

        MGSA_SAMPMSG("Instalirano: " .. rrr)
    end


    MGSA_SAMPMSG("Update uspjesno zavrsen!")

    return true
end