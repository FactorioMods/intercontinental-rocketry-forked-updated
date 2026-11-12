
Available_Planet_Locations={"alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon"}
for key, planet in pairs(data.raw["planet"]) do
    for _, location_name in pairs(Available_Planet_Locations) do
        if string.find(key, '-'..location_name) then

            x, _ = key:gsub('-'..location_name, "")
            local new_planet=table.deepcopy(data.raw["planet"][x])
            new_planet.localised_name =  planet.localised_name
            new_planet.localised_description = planet.localised_description
            new_planet.draw_orbit = planet.draw_orbit
            new_planet.name = planet.name
            new_planet.magnitude = planet.magnitude
            new_planet.hidden_in_factoriopedia = planet.hidden_in_factoriopedia
            new_planet.distance = planet.distance
            new_planet.map_seed_offset = planet.map_seed_offset
            new_planet.orientation = planet.orientation
            new_planet.label_orientation = planet.label_orientation
            data.raw["planet"][key] = new_planet
        end 
    end
end