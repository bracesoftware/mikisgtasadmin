local __MGSADialog__ = {}

function __MGSADialog__.show(title, text)
    MGSA_API.sampShowDialog(
        1987324, MESSAGE_HEADER .. " " .. COLOR_ELECTRIC_VIOLET .. title,
        COLOR_GRAY .. text, "OK", "",0
    )
end

function __MGSADialog__.load()
    MGSA_LOADED_MODULE({
        name = "Dialozi",
        desc = "Pruza funkcije za upravljanje dijalozima."
    })
end

return __MGSADialog__