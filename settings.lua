function int_settings_construct (planet)
    return {
        type = "int-setting",
        name = "irf-setting-planets-selection-"..planet,
        localised_name  = {"",{"irf-settings.setting-planets-selection"}, " ", {"space-location-name."..planet}},
        setting_type = "startup",
        minimum_value = 0,
        maximum_value = 20,
        default_value = 2
    }
end

data:extend({
    {
        type = "bool-setting",
        name = "irf-settings-display-labels",
        localised_name  = {"",{"irf-settings.display-label"}, ""},
        setting_type = "startup",
        default_value = false
    },
    int_settings_construct("nauvis"),
    int_settings_construct("vulcanus"),
    int_settings_construct("gleba"),
    int_settings_construct("fulgora"),
    int_settings_construct("aquilo")
})


if mods["naufulglebunusilo"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    data:extend({
        int_settings_construct("naufulglebunusilo")
    })
end

if mods["tenebris"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    data:extend({
        int_settings_construct("tenebris")
    })
end

if mods["terrapalus"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    data:extend({
        int_settings_construct("terrapalus")
    })
end

if mods["Factorio-Tiberium"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    data:extend({
        int_settings_construct("tiber")
    })
end

if mods["Cerys-Moon-of-Fulgora"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    data:extend({
        int_settings_construct("cerys")
    })
end

if mods["metal-and-stars"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    data:extend({
        int_settings_construct("nix"),
        int_settings_construct("ringworld"),
        int_settings_construct("shipyard"),
    })
end