local __MGSADialog__ = {}

function __MGSADialog__.show(title, text)
    MGSA_CHRONO.task(
        0.5,
        function (id)
            MGSA_API.sampShowDialog(
                1987324, MESSAGE_HEADER .. " " .. COLOR_ELECTRIC_VIOLET .. title,
                COLOR_GRAY .. text, COLOR_GOLD.."U redu", "",0
            )
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

return __MGSADialog__