--provjerava validnost pointera
local function __0(pointer)
    return pointer ~= nil and pointer ~= MGSA_FFI.NULL
end
--vraca verziju
local function __1()
    if not MGSA_SAMP_API or
       type(MGSA_SAMP_API.GetSAMPVersion) ~= "function" then
        return nil
    end

    local ok, version = pcall(MGSA_SAMP_API.GetSAMPVersion)

    if not ok then
        return nil
    end

    return version
end
--validan pointer
local function __2(refFunction)
    if type(refFunction) ~= "function" then
        return nil
    end

    local ok, pointer = pcall(refFunction)

    if not ok or not __0(pointer) then
        return nil
    end

    if __1() == 3 then
        local derefOk, object = pcall(function()
            return pointer[0]
        end)

        if not derefOk or not __0(object) then
            return nil
        end

        return object
    end

    return pointer
end
--Salje SAMP poruku u chat.
function MGSA_SAMPMSG(text)
    local chat = __2(MGSA_CChat.RefChat)
    print("MGSA_SAMPMSG: "..text)
    text = "[Miki's GTASAdmin]: "..text
    pcall(function (t)
        chat:AddEntry(8, t, "", 0xFFFFFFFF,0xFFFFFFFF)
    end, text)

end
--Pokrece azuriranje kompletnog sistema!
function MGSA_Update(githubinf,roooooot,downfunc)
    createDirectory(roooooot)
    local ok
    local result

    print("[MGSA] PROVJERAVAM AZURIRANJA...")
    MGSA_SAMPMSG("Provjeravam azuriranja...")

    local VERSION_NOW = "-"
    local VERSION_ON_SERVER = "--"

    ok, result = pcall(dofile, roooooot .. githubinf.VERSION)
    if ok or type(result) == "string" then
        VERSION_NOW = result
    end

    print("Trenutna verzija: v"..VERSION_NOW)
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
    if ok or type(result) == "string" then
        VERSION_ON_SERVER = result
    end

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

    local mainfile = "MikisGTASAdmin.lua"
    local tempFile = roooooot .. mainfile .. ".tmp"
    local mainPath = getWorkingDirectory() .. "\\" .. mainfile

    local ah = downfunc(
        githubinf.BASE_URL .. mainfile,
        tempFile
    )

    if ah then
        os.remove(mainPath)

        local renamed = os.rename(tempFile, mainPath)

        if renamed then
            MGSA_SAMPMSG("Uspjesno azuriran boot fajl.")
        else
            MGSA_SAMPMSG("Nije moguce zamijeniti glavni fajl.")
        end
    else
        MGSA_SAMPMSG("Nije uspesno azuriran glavni fajl.")
    end

    MGSA_SAMPMSG("Update uspjesno zavrsen!")

    return true
end