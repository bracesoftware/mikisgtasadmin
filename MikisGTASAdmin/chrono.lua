local __MGSAChrono__ = {}
__MGSAChrono__.timers = {}
__MGSAChrono__.nextId = 1

function __MGSAChrono__.task(delay, callback, repeating)
    assert(type(delay) == "number" and delay >= 0, "NE VALJANI BROJ!! -> "..tostring(delay))
    assert(type(callback) == "function", "NIJE FUNKCIJA")

    local id = __MGSAChrono__.nextId
    __MGSAChrono__.nextId = __MGSAChrono__.nextId + 1

    __MGSAChrono__.timers[id] = {
        id = id,
        delay = delay,
        callback = callback,
        repeating = repeating and true or false,
        nextRun = os.clock() + delay
    }

    return id
end

function __MGSAChrono__.kill(id)
    __MGSAChrono__.timers[id] = nil
end

function __MGSAChrono__.__PROC()
    local now = os.clock()

    local dueIds = {}
    for id, T__ in pairs(__MGSAChrono__.timers) do
        if now >= T__.nextRun then
            dueIds[#dueIds + 1] = id
        end
    end

    for _, id in ipairs(dueIds) do
        local T__ = __MGSAChrono__.timers[id]
        if T__ then
            if T__.repeating then
                T__.nextRun = T__.nextRun + T__.delay
                if T__.nextRun < now then
                    T__.nextRun = now + T__.delay
                end
            else
                __MGSAChrono__.timers[id] = nil
            end

            local ok, err = pcall(T__.callback, id)
            if not ok then
                print("[MGSA] Pukao task ".. id.." -> "..err)
                if T__.repeating then
                    __MGSAChrono__.timers[id] = nil
                end
            end
        end
    end
end

return __MGSAChrono__