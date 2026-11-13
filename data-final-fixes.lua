
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
            -- Preserve the child orbit after PlanetsLib converts it to native coordinates.
            new_planet.origin = table.deepcopy(planet.origin)
            new_planet.orbit = table.deepcopy(planet.orbit)
            new_planet.map_seed_offset = planet.map_seed_offset
            new_planet.orientation = planet.orientation
            new_planet.label_orientation = planet.label_orientation
            data.raw["planet"][key] = new_planet
        end 
    end
end

-- Normalize only evidenced route pairs after optional Redrawn generation.
-- Reuse the same prototype object; all fields except its name remain untouched.
for _,rule in ipairs(require("route-identity").pairs) do
  local found
  for name,connection in pairs(data.raw["space-connection"]) do
    if (connection.from==rule.a and connection.to==rule.b)
      or (connection.from==rule.b and connection.to==rule.a) then
      assert(not found,"IRF stable route identity found multiple physical routes for "..rule.name)
      found={name=name,prototype=connection}
    end
  end
  if found and found.name~=rule.name then
    assert(found.name==rule.b.."-"..rule.a,"IRF route has an unknown identity: "..found.name)
    data.raw["space-connection"][found.name]=nil
    found.prototype.name=rule.name
    data.raw["space-connection"][rule.name]=found.prototype
  end
end
