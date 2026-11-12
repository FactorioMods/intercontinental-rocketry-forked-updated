local planets={"nauvis", "vulcanus", "gleba", "fulgora", "aquilo"}

if mods["naufulglebunusilo"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    table.insert(planets,"naufulglebunusilo")
end
if mods["tenebris"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    table.insert(planets,"tenebris")
end
if mods["terrapalus"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    table.insert(planets,"terrapalus")
end
if mods["Factorio-Tiberium"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    table.insert(planets,"tiber")
end
if mods["Cerys-Moon-of-Fulgora"] then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    table.insert(planets,"cerys")
end
if (mods["metal-and-stars"] or mods["metal-and-stars-updated"]) then --Other known modded planets should be appended in this section. This mod appears to be one of the first modded planets.
    table.insert(planets,"nix")
    table.insert(planets,"ringworld")
    table.insert(planets,"shipyard")
end

-- Planet_Locations={"north","west","east","south","temperate-south","temperate-north"}
Available_Planet_Locations={"alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon"}

Planet_Locations_2d={}
Planet_Locations_orientation_mod_2d={}
Planet_Random_Number_Location_Offset={}

Planet_Locations_seed_offset={}

for i,planet_location in ipairs(Available_Planet_Locations) do
    Planet_Locations_seed_offset[i]=math.random(2^32)
    
    for _, value in ipairs(planets) do
        if i == 1 then
            Planet_Locations_2d[value] = {}
            Planet_Locations_orientation_mod_2d[value] = {}
            Planet_Random_Number_Location_Offset[value] = {}
            table.insert(Planet_Random_Number_Location_Offset[value], math.random())
        end
        if i <= settings.startup["irf-setting-planets-selection-"..value].value then
            table.insert(Planet_Locations_2d[value], planet_location)
            table.insert(Planet_Locations_orientation_mod_2d[value], ((i/settings.startup["irf-setting-planets-selection-"..value].value) + Planet_Random_Number_Location_Offset[value][1])%1)
        end
    end
end

for i,planet in ipairs(planets) do
    local old_planet=data.raw["planet"][planet]
    if old_planet == nil then 
        goto continue
    end
    
    old_planet.label_orientation = old_planet.orientation
    for j,planet_location in ipairs(Planet_Locations_2d[planet]) do
        local new_planet=table.deepcopy(data.raw["planet"][planet])

        if settings.startup["irf-settings-display-labels"].value then
            new_planet.localised_name={"",{"space-location-name."..planet}," ",{"subplanet-name."..planet_location}}
        else
            new_planet.localised_name=""
        end

        new_planet.localised_description={"",{"space-location-name."..planet},", ",{"subplanet-description."..planet_location}}
        new_planet.draw_orbit = false
        new_planet.name=old_planet.name .. "-"..planet_location
        new_planet.magnitude=old_planet.magnitude/1.5
        new_planet.hidden_in_factoriopedia = true
        new_planet.map_seed_offset=Planet_Locations_seed_offset[j]
        new_planet.label_orientation = Planet_Locations_orientation_mod_2d[planet][j]

        local from_planet = planet
        local length_multiplier =0.25
        local new_connection= {
            type="space-connection",
            name=new_planet.name.."-"..planet,
            subgroup = "planet-connections",
            to=new_planet.name,
            from=from_planet,
            order = "aa",
            length=500*old_planet.magnitude*length_multiplier,
            hidden_in_factoriopedia = true
        }
        if planet ~= "nauvis" and old_planet.subgroup ~= "satellites" then
            table.insert(data.raw["technology"]["planet-discovery-"..planet].effects,{
                type = "unlock-space-location",
                space_location = new_planet.name,
                use_icon_overlay_constant = true
            })
        end
        if planet == "nauvis" then          
            table.insert(data.raw["technology"]["space-platform-thruster"].effects,{
                type = "unlock-space-location",
                space_location = new_planet.name,
                use_icon_overlay_constant = true
            })
        end
        data:extend({new_planet,new_connection})
        
        if j%2==1 then
            prevPlanet1 = new_planet.name
        else
            prevPlanet2 = new_planet.name
        end

        PlanetsLib:update({
            {
                type = old_planet.type,
                name = new_planet.name,
                orbit = {
                    parent = {
                        type = "planet",
                        name = old_planet.name,
                    },
                    distance = 1.3,
                    orientation = Planet_Locations_orientation_mod_2d[planet][j]
                }
            }
        })
    end
    ::continue::
end
