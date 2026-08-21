---@diagnostic disable: lowercase-global
function has(item, amount)
  local count = Tracker:ProviderCountForCode(item)
  amount = tonumber(amount)
  if not amount then
    return count > 0
  else
    return count == amount
  end
end

--========================================================================

--========================================================================
-- Foundations
function canBuild()
  local cb = Tracker:FindObjectForCode("can_build")
  if not cb
  then
    return
  end

  local foundation_items = {"thatch_foundation", "wood_foundation", "stone_foundation"}
  local ok = false

  for _, f in ipairs(foundation_items) do
    if has(f)
    then
      ok = true
      break
    end
  end

  cb.Active = ok
end

ScriptHost:AddWatchForCode("foundation watch", "*", canBuild)
--=====================================================================

--=====================================================================
--Water
function storeWater()
  local sw = Tracker:FindObjectForCode("store_water")
  if not sw
  then
    return
  end

  local waterContainer = {"waterskin", "water_jar", "canteen"}
  local ok = false

  for _, f in ipairs(waterContainer) do
    if has(f)
    then
      ok = true
      break
    end
  end

  sw.Active = ok
end

ScriptHost:AddWatchForCode("water watch", "*", storeWater)
--==================================================================

--==================================================================
--Crops
function growCrops()
  local gc = Tracker:FindObjectForCode("grow_crops")
  if not gc
  then
    return
  end

  local cropPlot = {"medium_plot", "large_plot"}
  local ok = false

  for _, f in ipairs(cropPlot) do 
    if has(f) and has("store_water")
    then
      ok = true
      break
    elseif has(f) and has("irrigation")
    then
      ok = true
      break
    end 
  end

  gc.Active = ok
end

ScriptHost:AddWatchForCode("crop watch", "*", growCrops)
--==================================================================

--==================================================================
--Power
function usePower()
  local up = Tracker:FindObjectForCode("use_power")
  if not up
  then
    return
  end

  local cable = {"straight_cable", "vertical_cable"}
  local ok = false

  for _, f in ipairs(cable) do 
    if has(f) and has("outlet") and has("fabricator") and has("basic_forge") and has("electronics") and has("polymer")and (has("generator") or has("wind_turbine"))
    then
      ok = true
      break
    end
  end

  up.Active = ok
end

ScriptHost:AddWatchForCode("power watch", "*", usePower)
--===================================================================

--===================================================================
--Irrigation
function Irrigation()
  local ci = Tracker:FindObjectForCode("irrigation")
  if not ci
  then
    return
  end

  local stone = {"stone_intake", "stone_tap"}
  local metal = {"smithy", "metal_intake", "metal_tap"}

  local function hasAll(items)
    for _, item in ipairs(items) do
      if not has(item)
      then
        return false
      end
    end
    return true
  end

  local ok = hasAll(stone) or hasAll(metal)

  ci.Active = ok
end

ScriptHost:AddWatchForCode("irrigation watch", "*", Irrigation)
--===================================================================

--===================================================================
--Smithy
function UseSmithy()
  local smithy = Tracker:FindObjectForCode("use_smithy")
  if not smithy
  then
    return
  end

  local requirements = {"smithy", "can_build", "basic_forge"}

  local function hasAll(items)
    for _, item in ipairs(items) do
      if not has(item) then
        return false
      end
    end
    return true
  end

  local ok = hasAll(requirements)

  smithy.Active = ok
end

ScriptHost:AddWatchForCode("smithy watch", "*", UseSmithy)
--=======================================================================

--=======================================================================
--Use Tree Taps
function UseTaps()
  local taps = Tracker:FindObjectForCode("can_tree_tap")
  if not taps
  then
    return
  end

  local platform = {"wooden_tree_platform", "metal_tree_platform", "glass_tree_platform", "stone_tree_platform"}
  local ok = false

  for _, f in ipairs(platform) do
    if has(f) and has("use_smithy") and CanFly()
    then
      ok = true
      break
    elseif has(f) and has("use_smithy") and UseGrapple()
    then
      ok = true
      break
    end
  end

  taps.Active = ok
end

ScriptHost:AddWatchForCode("taps watch", "*", UseTaps)

--=======================================================================

--=======================================================================
--Saddle Check
local function has_tame_and_saddle(entry_code)
    if type(entry_code) == "string"
    then
        return Tracker:ProviderCountForCode(entry_code) > 0
    elseif type(entry_code) == "table"
    then
        for _, code in ipairs(entry_code) do
            if Tracker:ProviderCountForCode(code) == 0
            then
                return false
            end
        end
        return true
    end
    return false
end
--=========================================================================

--=========================================================================
-- Shallow tame logic
local shallow_tames_list = {
    { code = { "megalodon", "megalodon_saddle" },can_fight = true },
    { code = { "sarco", "sarco_saddle" }, can_fight = true },
    { code = { "baryonyx", "baryonyx_saddle" },can_fight = true },
    { code = "diplocaulus",can_fight = false },
    { code = { "manta", "manta_saddle" }, can_fight = false },
    { code = { "basilosaurus", "basilosaurus_saddle" },can_fight = true },
    { code = { "beelzebufo", "beelzebufo_saddle" },can_fight = true },
    { code = { "icthysaurus", "icthysaurus_saddle" },can_fight = true },
    { code = { "casteroides", "casteroides_saddle" }, can_fight = true },
    { code = { "kaprosuchus", "kaprosuchus_saddle" },can_fight = true },
    { code = { "allosaurus", "allosaurus_saddle" },can_fight = true }
}

function shallow_tames()
    for _, tame in ipairs(shallow_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end

function shallow_tames_combat()
    for _, tame in ipairs(shallow_tames_list) do
        if tame.can_fight and has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=====================================================================

--=====================================================================
--Deep tame logic
local deep_tames_list = {
    { code = { "mosasaur", "mosasaur_saddle" },can_fight = true },
    { code = { "plesiosaur", "plesiosaur_saddle" }, can_fight = true },
    { code = "lioplurodon" ,can_fight = false },
    { code = {"dunkleosteus", "dunkleosteus_saddle"},can_fight = false },
    { code = "angler",can_fight = false },
    { code = { "tusoteuthis", "tusoteuthis_saddle" },can_fight = true }
}

function deep_tames()
    for _, tame in ipairs(deep_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end

function deep_tames_combat()
    for _, tame in ipairs(deep_tames_list) do
        if tame.can_fight and has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=====================================================================

--=====================================================================
--Can Fly Logic
local flyer_list = {
    { code = { "argentavis", "argentavis_saddle" }},
    { code = { "pelagornis", "pelagornis_saddle" }},
    { code = { "pteranodon", "pteranodon_saddle"}},
    { code = { "quetzal", "quetzal_saddle" }},
    { code = { "rhyniognatha", "rhyniognatha_saddle" }},
    { code = { "tapejara", "tapejara_saddle" }}
}

function CanFly()
    for _, tame in ipairs(flyer_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=====================================================================

--=====================================================================
--Basic Fight Tames
local basic_fight_tames_list = {
    { code = { "iguanadon", "iguanadon_saddle" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "moschops" }},
    { code = { "pteranodon", "pteranodon_saddle" }},
    { code = { "pelagornis", "pelagornis_saddle" }},
    { code = { "ankylosaurus", "ankylosaurus_saddle" }},
    { code = { "carbonemys", "carbonemys_saddle" }},
    { code = { "castoroides", "castoroides_saddle" }},
    { code = { "araneo", "araneo_saddle" }},
    { code = { "arthropluera", "arthropluera_saddle" }},
    { code = { "doedicurus", "doedicurus_saddle" }},
    { code = { "beelzebufo", "beelzebufo_saddle" }},
    { code = { "gallimimus", "gallimimus_saddle" }},
    { code = { "equus" }},
    { code = { "unicorn" }},
    { code = { "pulmonoscorpius", "pulmonoscorpius_saddle" }},
    { code = { "gigantopithecus" }}
}

function BasicFightTames()
    for _, tame in ipairs(basic_fight_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=======================================================================

--=======================================================================
--Medium Fight Tames
local medium_fight_tames_list = {
    { code = { "argentavis", "argentavis_saddle" }},
    { code = { "daeodon", "daeodon_saddle" }},
    { code = { "chalicotherium", "chalicotherium_saddle" }},
    { code = { "carno", "carno_saddle" }},
    { code = { "sarco", "sarco_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "mammoth", "mammoth_saddle" }},
    { code = { "woolly_rhino", "woolly_rhino_saddle" }},
    { code = { "direbear", "direbear_saddle" }},
    { code = { "allosaurus", "allosaurus_saddle" }},
    { code = { "kaprosuchus", "kaprosuchus_saddle" }},
    { code = { "terror_bird", "terrorbird_saddle" }},
    { code = { "quetzal", "quetzal_saddle" }},
    { code = { "trike", "triceratops_saddle" }},
    { code = { "stegosaurus", "stegosaurus_saddle" }},
    { code = { "bronto", "bronto_saddle" }},
    { code = { "direwolf" }}
}

function MediumFightTames()
    for _, tame in ipairs(medium_fight_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=========================================================================

--=========================================================================
--Strong Fight Tames
local strong_fight_tames_list = {
    { code = { "rex", "rex_saddle" }},
    { code = { "therizinosaur", "therizinosaur_saddle" }},
    { code = { "spino", "spino_saddle" }},
    { code = { "yutyrannus", "yutyrannus_saddle" }},
    { code = { "titanosaur", "titanosaur_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
    { code = { "rhyniognatha", "rhyniognatha_saddle" }}
}

function StrongFightTames()
    for _, tame in ipairs(strong_fight_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=========================================================================

--=========================================================================
--Insane Fight Tames
local insane_fight_tames_list = {
    { code = { "giganotosaurus", "giganotosaurus_saddle" }},
    { code = { "carchardontosaurus", "carchardontosaurus_saddle" }}
}

function InsaneFightTames()
    for _, tame in ipairs(insane_fight_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--==========================================================================

--==========================================================================
--Immune Useful Tames
local immune_tames_list = {
    { code = { "beelzebufo", "beelzebufo_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }}
}

function ImmuneTames()
    for _, tame in ipairs(immune_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--==========================================================================

--==========================================================================
--Strong Useful Tames
local strong_tames_list = {
    { code = { "allosaurus", "allosaurus_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
    { code = { "yutyrannus", "yutyrannus_saddle"}}
}

function StrongTames()
    for _, tame in ipairs(strong_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--==========================================================================

--==========================================================================
--Massive Useful Tames
local massive_tames_list = {
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "direwolf" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function MassiveTames()
    for _, tame in ipairs(massive_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end

--==========================================================================

--==========================================================================
--Clever Useful Tames
local clever_tames_list = {
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "direwolf" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function CleverTames()
    for _, tame in ipairs(clever_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=========================================================================

--=========================================================================
--Pack Useful Tames
local pack_tames_list = {
    { code = { "sarco", "sarco_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function PackTames()
    for _, tame in ipairs(pack_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=========================================================================

--=========================================================================
-- Hunter Useful Tames
local hunter_tames_list = {
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "direwolf" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function HunterTames()
    for _, tame in ipairs(hunter_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=========================================================================

--=========================================================================
-- Devourer Useful Tames
local devourer_tames_list = {
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "direwolf" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function DevourerTames()
    for _, tame in ipairs(devourer_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--=======================================================================
-- Central Useful Tames
local central_tames_list = {
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "direwolf" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function CentralTames()
    for _, tame in ipairs(central_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end
--========================================================================

--========================================================================
-- Upper South Tames
local upper_south_tames_list = {
    { code = { "sarco", "sarco_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function UpperSouthTames()
    for _, tame in ipairs(upper_south_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end

--========================================================================

--========================================================================
-- Lower South Tames
local lower_south_tames_list = {
    { code = { "sabertooth", "sabertooth_saddle" }},
    { code = { "baryonyx", "baryonyx_saddle" }},
    { code = { "direwolf" }},
    { code = { "raptor", "raptor_saddle" }},
    { code = { "thylacoleo", "thylacoleo_saddle" }},
}

function LowerSouthTames()
    for _, tame in ipairs(lower_south_tames_list) do
        if has_tame_and_saddle(tame.code)
        then
            return true
        end
    end
    return false
end

--========================================================================

--========================================================================
--Enter Snow
function EnterSnow()
  local requirements = {"fur_boots", "fur_leggings", "fur_gloves", "fur_chestpiece", "fur_helmet", "otter"}
  local count = 0

  for _, item in ipairs(requirements) do
    if has(item)
    then
      count = count + 1
    end
  end

  return count >= 2
end

function SnowMountains()
  local fur = {"fur_boots", "fur_leggings", "fur_gloves", "fur_chestpiece", "fur_helmet", "otter"}
  local count = 0

  for _, item in ipairs(fur) do
    if has(item)
    then
      count = count + 1
    end
  end

  return count >= 4
end
--==========================================================================

--==========================================================================
--Swamp Cave Logic
function EnterSwampCave()
  if CraftGasMask()
  then
    return true
  end

  local scubarequirements = {"scuba_tank", "scuba_mask", "scuba_flippers", "scuba_legs"}
  local ghillierequirements = {"ghillie_mask", "ghillie_legs", "ghillie_gloves", "ghillie_chest", "ghillie_boots"}
  local scubacount = 0
  for _, item in ipairs(scubarequirements) do
    if has(item)
    then
      scubacount = scubacount + 1
    end
  end
  local ghilliecount = 0
  for _, item in ipairs(ghillierequirements) do
    if has(item)
    then
      ghilliecount = ghilliecount + 1
    end
  end

  if scubacount == 4
  -- or (scubacount == 3 and ghilliecount == 2) ADD TO HIGH DIFFICULTY
  then
    return true
  else return false
  end
end
--==========================================================================

--=========================================================================
-- Snow Cave Logic
function EnterSnowCave()
  local fur = {"fur_boots", "fur_leggings", "fur_gloves", "fur_chestpiece", "fur_helmet", "otter"}
  local furcount = 0

  for _, item in ipairs(fur) do
    if has(item)
    then
      furcount = furcount + 1
    end
  end
  return furcount >= 4 and has("grenade")and has("cryopod") and StrongTames()
end
--==========================================================================

--==========================================================================
-- Ice Cave Logic
function EnterIceCave()
  local fur = {"fur_boots", "fur_leggings", "fur_gloves", "fur_chestpiece", "fur_helmet", "otter"}
  local furcount = 0

  for _, item in ipairs(fur) do
    if has(item)
    then
      furcount = furcount + 1
    end
  end
  return furcount >= 3 and (UseShotgun() or AdvancedMelee())
end
--=========================================================================

--=========================================================================
-- Lava Cave Logic
function EnterLavaCave()
  if has("store_water") and has("otter") and (MassiveTames() or UseShotgun() or UseRifle())
  then
    return true
  else
    return false
  end
end
--=========================================================================

--=========================================================================
-- Carno Cave Logic
function EnterCarnoCave()
  if DevourerTames() or UseShotgun() or UseRifle()
  then
    return true
  else
    return false
  end
end
--========================================================================

--========================================================================
-- Central Cave Logic
function EnterCentralCave()
  if CentralTames() or UseShotgun() or UseRifle()
  then
    return true
  else
    return false
  end
end
--========================================================================

--========================================================================
-- Upper South Logic
function EnterUpperSouthCave()
  if UpperSouthTames() or UseGrapple()
  then
    return true
  else
    return false
  end
end
--========================================================================

--========================================================================
-- Lower South Logic
function EnterLowerSouthCave()
  if LowerSouthTames() or UseShotgun() or AdvancedMelee()
  then
    return true
  else
    return false
  end
end

--========================================================================

--========================================================================
-- if has functions
function CanUseMortar()
  if has("can_build") and has("mortar")
  then
    return true
  else
    return false
  end
end

function CanUseFabricator()
  if has("use_smithy") and has("fabricator") and has("sparkpowder") and CanUseMortar()
  then
    return true
  else
    return false
  end
end

function CanCraftCrossbow()
  if has("use_smithy") and has ("crossbow")
  then
    return true
  else
    return false
  end
end

function CanCraftTranqArrows()
  if CanUseMortar() and has("stone_arrow") and has("tranq_arrow")
  then
    return true
  else
    return false
  end
end

function CraftCharcoal()
  if has("campfire") or has("cooking_pot")
  then
    return true
  elseif canBuild() and has("basic_forge")
  then
    return true
  elseif CanUseFabricator() and has("indutrial_forge")
  then
    return true
  else
    return false
  end
end

function CraftGunpowder()
  if CanUseMortar() and has("sparkpowder") and has("gunpowder") and CraftCharcoal()
  then
    return true
  else return false
  end
end

function CrossbowKO()
  if CanCraftCrossbow() and CanCraftTranqArrows()
  then
    return true
  else
    return false
  end
end

function DeepDive()
  if has("scuba_tank") and has("scuba_mask") and has("fabricator")
  then
    return true
  else
    return false
  end
end

function UseNets()
  if has("use_smithy") and has("harpoon_gun") and has("net_projectile")
  then return true
  else
    return false
  end
end

function CanBleed()
  if has("thylacoleo") and has("thylacoleo_saddle")
  then
    return true
  elseif has("allosaurus") and has ("allosaurus_saddle")
  then
    return true
  else
    return false
  end
end

function tier1()
  if has("mortar") and has("basic_forge") and has("can_build")
  then
    return true
  else
    return false
  end
end

function tier2()
  if tier1() and has("use_smithy")
  then
    return true
  else
    return false
  end
end

function tier3()
  if tier2() and CanUseFabricator()
  then
    return true
  else
    return false
  end
end

function UseGrapple()
  if CanCraftCrossbow() and has("grapple")
  then
    return true
  else
    return false
  end
end

function UseArrows()
  if (CanCraftCrossbow() or has("bow")) and has("stone_arrow")
  then
    return true
  else return false
  end
end

function UsePistol()
  if has("use_smithy") and has("simple_pistol") and CraftGunpowder() and has("simple_bullet")
  then
    return true
  elseif has("fabricated_pistol") and CraftGunpowder() and CanUseFabricator() and has("advanced_bullet")
  then
    return true
  else
    return false
  end
end

function UseShotgun()
  if has("use_smithy") and has("simple_bullet") and has("simple_shotgun_ammo") and CraftGunpowder() and has("simple_shotgun")
  then
    return true
  elseif has("use_smithy") and CraftGunpowder() and has("simple_bullet") and has("simple_shotgun_ammo") and CanUseFabricator() and has("pump_shotgun")
  then
    return true
  else
    return false
  end
end

function UseRifle()
  if has("use_smithy") and CraftGunpowder() and has("longneck") and has("simple_rifle_ammo")
  then
    return true
    elseif CanUseFabricator() and CraftGunpowder() and has("fabricated_sniper") and has("advanced_sniper_ammo")
    then
      return true
    else
      return false
  end
end

function AdvancedMelee()
  if has("use_smithy") and ( has("pike") or has("sword") )
  then
    return true
  else
    return false
  end
end

function PrimMelee()
  if has("spear") or has("stone_hatchet") or has("stone_pick")
  then
    return true
  else
    return false
  end
end

function UseMelee()
  if PrimMelee() or AdvancedMelee()
  then
    return true
  else
    return false
  end
end

function RifleKO()
  if has("use_smithy") and has("longneck") and has("simple_rifle_ammo") and has ("tranq_dart") and CanUseMortar() and has("narcotic") and CraftGunpowder()
  then
    return true
  else
    return false
  end
end

function UseCrossbow()
  if CanCraftCrossbow() and has("stone_arrow")
  then
    return true
  else
    return false
  end
end

function UseFabSniper()
  if CanUseFabricator() and has("fabricated_sniper") and has("advanced_sniper_ammosniper_ammo")
  then
    return true
  else
    return false
  end
end

function MakeCake()
  if ((has("cooking_pot") and has("store_water")) or
      (has("industrial_cooker") and has("irrigation")))
      and has("can_tree_tap") and has("grow_crops")
      and has("can_build") and has("mortar") and has("stimulant")
  then
    return true
  else
    return false
  end
end


function CraftGasMask()
  if has("use_power") and has("subsrate") and has("gas_mask")
  then
    return true
  else
    return false
  end
end

function OceanArtifactTames()
  if has("diplocaulus_tame")
  or (has("ichthyosaurus") and has("ichthyosaurus_saddle"))
  or (has("tusoteuthis") and has("tusoteuthis_saddle"))
  then
    return true
  else
    return false
  end
end
