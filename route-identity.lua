local route_pairs = {
  {a="calidus-senestella-gate-calidus",b="gleba",name="calidus-senestella-gate-calidus-gleba"},
  {a="calidus-senestella-gate-calidus",b="nauvis-alpha",name="calidus-senestella-gate-calidus-nauvis-alpha"},
  {a="fulgora",b="fulgora-beta",name="fulgora-fulgora-beta",parent="fulgora",child="fulgora-beta"},
  {a="gleba",b="nauvis-alpha",name="gleba-nauvis-alpha"},
  {a="gleba",b="nauvis",name="gleba-nauvis"},
  {a="nauvis",b="vulcanus",name="nauvis-vulcanus"},
  {a="nix",b="nix-beta",name="nix-nix-beta",parent="nix",child="nix-beta"},
  {a="ringworld-alpha",b="shipyard-alpha",name="ringworld-alpha-shipyard-alpha"},
  {a="ringworld",b="ringworld-alpha",name="ringworld-ringworld-alpha",parent="ringworld",child="ringworld-alpha"},
  {a="ringworld",b="shipyard-beta",name="ringworld-shipyard-beta"},
  {a="nix-beta",b="shipyard-alpha",name="nix-beta-shipyard-alpha"},
  {a="nix",b="shipyard",name="nix-shipyard"},
  {a="nix-beta",b="shipyard",name="nix-beta-shipyard"},
  {a="shipyard",b="shipyard-beta",name="shipyard-shipyard-beta",parent="shipyard",child="shipyard-beta"},
  {a="fulgora-alpha",b="nauvis-alpha",name="fulgora-alpha-nauvis-alpha"},
  {a="fulgora",b="fulgora-alpha",name="fulgora-fulgora-alpha",parent="fulgora",child="fulgora-alpha"},
  {a="fulgora",b="nauvis-alpha",name="fulgora-nauvis-alpha"},
  {a="gleba-alpha",b="nauvis-alpha",name="gleba-alpha-nauvis-alpha"},
  {a="fulgora-alpha",b="slp-solar-system-sun2",name="fulgora-alpha-slp-solar-system-sun2"},
  {a="nauvis",b="slp-solar-system-sun2",name="nauvis-slp-solar-system-sun2"},
  {a="gleba",b="vulcanus",name="gleba-vulcanus"},
  {a="gleba-alpha",b="vulcanus",name="gleba-alpha-vulcanus"},
  {a="slp-solar-system-sun",b="vulcanus",name="slp-solar-system-sun-vulcanus"},
}
local M={pairs=route_pairs}
local function current_orientations()
  local out={}
  for _,rule in ipairs(route_pairs) do
    local connection=prototypes.space_connection[rule.name]
    if connection then out[rule.name]={from=connection.from.name,to=connection.to.name} end
  end
  return out
end
function M.init()
  if not storage.__irf_route_identity_v1 then
    storage.__irf_route_identity_v1={orientations=current_orientations(),new_instance=true}
  end
end
function M.migrate(event)
  local state=storage.__irf_route_identity_v1
  local changes=event.mod_changes or {}
  local routes=(event.migrations or {})["space-connection"] or {}
  local original=changes["intercontinental-rocketry-forked"]
  local own=changes[script.mod_name]
  local initial=not state or (state.new_instance and
    ((original and original.old_version) or (own and not own.old_version)))
  local old_ids={}
  for _,rule in ipairs(route_pairs) do
    local reverse=rule.b.."-"..rule.a
    if routes[reverse]==rule.name then old_ids[rule.name]=reverse end
  end
  local redrawn_change=changes["Redrawn-Space-Connections"]
  local had_redrawn
  if redrawn_change then had_redrawn=redrawn_change.old_version~=nil
  else had_redrawn=script.active_mods["Redrawn-Space-Connections"]~=nil end
  local known={};for _,rule in ipairs(route_pairs) do known[rule.name]=rule end
  local mirrored=0
  for _,force in pairs(game.forces) do
    for _,platform in pairs(force.platforms) do
      local connection=platform.space_connection
      local rule=connection and known[connection.name]
      if rule and platform.distance then
        local old_from,old_to
        if initial then
          -- An omitted identity migration means the old ID was already canonical.
          local old=old_ids[rule.name] or rule.name
          old_from,old_to=rule.a,rule.b
          if old==rule.b.."-"..rule.a then old_from,old_to=rule.b,rule.a end
          -- IRF names its own spokes child-parent but defines parent-to-child.
          -- Redrawn names each generated connection from its actual from/to.
          if not had_redrawn and rule.parent and old==rule.child.."-"..rule.parent then
            old_from,old_to=rule.parent,rule.child
          end
        else
          local previous=state.orientations[rule.name]
          old_from,old_to=previous and previous.from or connection.from.name,
            previous and previous.to or connection.to.name
        end
        assert((connection.from.name==old_from and connection.to.name==old_to)
          or (connection.from.name==old_to and connection.to.name==old_from),
          "IRF route migration endpoints changed")
        if connection.from.name~=old_from then
          local distance=platform.distance
          platform.distance=1-distance
          mirrored=mirrored+1
        end
      end
    end
  end
  -- Capture the current orientation even on fresh worlds or unrelated changes.
  -- Later Redrawn rebuilds can reverse a stable-ID body without changing its ID.
  storage.__irf_route_identity_v1={orientations=current_orientations(),new_instance=false}
  log("IRF stable route identity migration: corrected "..mirrored.." platform orientations")
end
return M
