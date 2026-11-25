local __MGSADialog__ = {
    pending = false
}

function __MGSADialog__.show(title, text)
    sendInfoMessage("Ucitavanje podataka...")
    __MGSADialog__.pending = true
    MGSA_CHRONO.task(
        0.3,
        function (id)
            MGSA_API.sampShowDialog(
                1987324, MESSAGE_HEADER .. " " .. COLOR_ELECTRIC_VIOLET .. title,
                COLOR_GRAY .. text, COLOR_GOLD.."U redu", "",0
            )
            __MGSADialog__.pending = false
        end,
        false
    )
end

function __MGSADialog__.load()
    MGSA_LOADED_MODULE({
        name = "Dialozi",
        desc = "Pruza funkcije za upravljanje dijalozima."
    })
end

function __MGSADialog__.isPendingDialog()
    return __MGSADialog__.pending
end

return __MGSADialog__