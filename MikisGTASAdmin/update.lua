function MGSA_Update(githubinf,roooooot,downfunc)
    createDirectory(roooooot)
    local ok
    local result

    print("[MGSA] PROVJERAVAM AZURIRANJA...")

    local VERSION_NOW = 0
    ok, result = pcall(dofile, roooooot .. githubinf.VERSION)
    if not ok or type(result) ~= "string" then
        VERSION_NOW = -1
    else VERSION_NOW = result end

    print("Trenutna verzija: v"..VERSION_NOW)

    local VERSION_ON_SERVER = 0
    print("SKIDAM INFORMACIJE O NAJNOVIJOJ VERZIJI")
    local ver = downfunc(
        githubinf.BASE_URL.."MikisGTASAdmin/".. githubinf.VERSION,
        roooooot .. githubinf.VERSION
    )

    if not ver then
        print("Nije moguce preuzeti informacije o verziji!")
        return false
    end

    ok, result = pcall(dofile, roooooot .. githubinf.VERSION)
    if not ok or type(result) ~= "string" then
        VERSION_ON_SERVER = -1
    else VERSION_ON_SERVER = result end

    if VERSION_ON_SERVER == VERSION_NOW then
        print("Nema novih azuriranja!")
        return true
    end

    print("[MGSA] NOVI UPDATE: " .. VERSION_ON_SERVER)
    print("[MGSA] SKIDAM UPDATE...")

    print("SKIDAM MANIFEST")
    local manifest = downfunc(
        githubinf.BASE_URL.."MikisGTASAdmin/"..githubinf.MANIFEST,
        roooooot .. githubinf.MANIFEST
    )

    if not manifest then
        print("Nije moguce preuzeti manifest!")
        return false
    end

    ok, result = pcall(dofile, roooooot .. githubinf.MANIFEST)

    if not ok or type(result) ~= "table" then
        print("[MGSA] INVALIDAN MANIFEST!")
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

        print("[MGSA] SKIDANJE: " .. rrr)


        if not downfunc(
            githubinf.BASE_URL .. file,
            tt
        ) then
            os.remove(tt)

            print("[MGSA] DOWNLOAD ERROR: " .. rrr)
            return false
        end

        local check = io.open(tt, "rb")

        if not check then
            print("[MGSA] FAJL NIJE PRONADJEN: " .. tt)
            return false
        end

        local size = check:seek("end")
        check:close()

        if not size or size == 0 then
            os.remove(tt)

            print("[MGSA] PRAZAN FAJL: " .. rrr)
            return false
        end

        os.remove(d)
        local rr, ee = os.rename(tt,d)

        if not rr then
            print("[MGSA] RENAME ERROR: " .. tostring(ee))
            print("[MGSA] TEMP: " .. tt)
            print("[MGSA] DEST: " .. d)

            return false
        end

        print("[MGSA] INSTALIRAN: " .. rrr)
    end


    print("[MGSA] UPDATE ZAVRSEN!")

    return true
end