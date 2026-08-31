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
  local metal = {"use_smithy", "metal_intake", "metal_tap"}

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

--========================================================================

--========================================================================
-- can ride tame
local function can_use_tame(tame_data)
    local loc_obj = Tracker:FindObjectForCode(tame_data.location)
    if not loc_obj then return false end

    local is_accessible = loc_obj.AccessibilityLevel >= 3
    local is_cleared = loc_obj.AvailableChestCount < loc_obj.ChestCount
    local location_valid = is_accessible or is_cleared
    local has_saddle = (tame_data.saddle == nil) or has(tame_data.saddle)

    return location_valid and has_saddle
end
--========================================================================

--========================================================================
-- Shallow Tames Logic
SHALLOW_TAMES_LIST = {
    baryonyx     = { location = "@Dinos/Baryonyx/Tame a Baryonyx",         saddle = "baryonyx_saddle",     can_fight = true },
    basilosaurus = { location = "@Dinos/Basilosaurus/Tame a Basilosaurus", saddle = "basilosaurus_saddle", can_fight = true },
    beelzebufo   = { location = "@Dinos/Beelzebufo/Tame a Beelzebufo",     saddle = "beelzebufo_saddle",   can_fight = true },
    castoroides  = { location = "@Dinos/Castoroides/Tame a Castoroides",   saddle = "castoroides_saddle",  can_fight = true },
    diplocaulus  = { location = "@Dinos/Diplocaulus/Tame a Diplocaulus",   saddle = nil,                   can_fight = false },
    ichthysaurus  = { location = "@Dinos/Ichthyosaurus/Tame a Ichthyosaurus", saddle = "ichthysaurus_saddle",  can_fight = true },
    kaprosuchus  = { location = "@Dinos/Kaprosuchus/Tame a Kaprosuchus",   saddle = "kaprosuchus_saddle",  can_fight = true },
    manta        = { location = "@Dinos/Manta/Tame a Manta",               saddle = "manta_saddle",        can_fight = false },
    megalodon    = { location = "@Dinos/Megalodon/Tame a Megalodon",       saddle = "megalodon_saddle",    can_fight = true },
    sarco        = { location = "@Dinos/Sarco/Tame a Sarco",               saddle = "sarco_saddle",        can_fight = true }
}

function shallow_tames()
    for _, tame in pairs(SHALLOW_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function shallow_tames_combat()
    for _, tame in pairs(SHALLOW_TAMES_LIST) do
        if tame.can_fight and can_use_tame(tame) then return true end
    end
    return false
end
--========================================================================

--========================================================================
--Deep Tames Logic
DEEP_TAMES_LIST = {
    angler       = { location = "@Dinos/Angler/Tame an Angler",               saddle = nil,                   can_fight = false },
    dunkleosteus = { location = "@Dinos/Dunkleosteus/Tame a Dunkleosteus",   saddle = "dunkleosteus_saddle", can_fight = false },
    liopleurodon  = { location = "@Dinos/Liopleurodon/Tame a Liopleurodon",     saddle = nil,                   can_fight = false },
    mosasaur     = { location = "@Dinos/Mosasaur/Tame a Mosasaur",           saddle = "mosasaur_saddle",     can_fight = true },
    plesiosaur   = { location = "@Dinos/Plesiosaur/Tame a Plesiosaur",       saddle = "plesiosaur_saddle",   can_fight = true },
    tusoteuthis  = { location = "@Dinos/Tusoteuthis/Tame a Tusoteuthis",     saddle = "tusoteuthis_saddle",  can_fight = true }
}

function deep_tames()
    for _, tame in pairs(DEEP_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function deep_tames_combat()
    for _, tame in pairs(DEEP_TAMES_LIST) do
        if tame.can_fight and can_use_tame(tame) then return true end
    end
    return false
end
--========================================================================

--========================================================================
--Can Fly Logic
FLYER_LIST = {
    argentavis   = { location = "@Dinos/Argentavis/Tame an Argentavis",     saddle = "argentavis_saddle" },
    pelagornis   = { location = "@Dinos/Pelagornis/Tame a Pelagornis",     saddle = "pelagornis_saddle" },
    pteranodon   = { location = "@Dinos/Pteranodon/Tame a Pteranodon",     saddle = "pteranodon_saddle" },
    quetzal      = { location = "@Dinos/Quetzal/Tame a Quetzal",           saddle = "quetzal_saddle" },
    rhyniognatha = { location = "@Dinos/Rhyniognatha/Tame a Rhyniognatha", saddle = "rhyniognatha_saddle" },
    tapejara     = { location = "@Dinos/Tapejara/Tame a Tapejara",         saddle = "tapejara_saddle" }
}

function CanFly()
    for _, tame in pairs(FLYER_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end
--========================================================================

--========================================================================
--Basic Fight Tames
BASIC_FIGHT_TAMES_LIST = {
    ankylosaurus    = { location = "@Dinos/Ankylosaurus/Tame an Ankylosaurus",       saddle = "ankylosaurus_saddle" },
    araneo          = { location = "@Dinos/Araneo/Tame an Araneo",                   saddle = "araneo_saddle" },
    arthropluera    = { location = "@Dinos/Arthropluera/Tame an Arthropluera",       saddle = "arthropluera_saddle" },
    beelzebufo      = { location = "@Dinos/Beelzebufo/Tame a Beelzebufo",           saddle = "beelzebufo_saddle" },
    carbonemys      = { location = "@Dinos/Carbonemys/Tame a Carbonemys",           saddle = "carbonemys_saddle" },
    castoroides     = { location = "@Dinos/Castoroides/Tame a Castoroides",         saddle = "castoroides_saddle" },
    doedicurus      = { location = "@Dinos/Doedicurus/Tame a Doedicurus",           saddle = "doedicurus_saddle" },
    equus           = { location = "@Dinos/Equus/Tame a Equus",                     saddle = nil },
    gallimimus      = { location = "@Dinos/Gallimimus/Tame a Gallimimus",           saddle = "gallimimus_saddle" },
    gigantopithecus = { location = "@Dinos/Gigantopithecus/Tame a Gigantopithecus", saddle = nil },
    iguanodon       = { location = "@Dinos/Iguanodon/Tame a Iguanodon",             saddle = "iguanodon_saddle" },
    moschops        = { location = "@Dinos/Moschops/Tame a Moschops",               saddle = nil },
    pelagornis      = { location = "@Dinos/Pelagornis/Tame a Pelagornis",           saddle = "pelagornis_saddle" },
    pteranodon      = { location = "@Dinos/Pteranodon/Tame a Pteranodon",           saddle = "pteranodon_saddle" },
    pulmonoscorpius = { location = "@Dinos/Pulmonoscorpius/Tame a Pulmonoscorpius", saddle = "pulmonoscorpius_saddle" },
    raptor          = { location = "@Dinos/Raptor/Tame a Raptor",                   saddle = "raptor_saddle" },
    sabertooth      = { location = "@Dinos/Sabertooth/Tame a Sabertooth",           saddle = "sabertooth_saddle" },
    unicorn         = { location = "@Dinos/Unicorn/Tame a Unicorn",                 saddle = nil }
}

function BasicFightTames()
    for _, tame in pairs(BASIC_FIGHT_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end
--========================================================================

--========================================================================
--Medium Fight Tames
MEDIUM_FIGHT_TAMES_LIST = {
    allosaurus     = { location = "@Dinos/Allosaurus/Tame an Allosaurus",        saddle = "allosaurus_saddle" },
    argentavis     = { location = "@Dinos/Argentavis/Tame an Argentavis",        saddle = "argentavis_saddle" },
    baryonyx       = { location = "@Dinos/Baryonyx/Tame a Baryonyx",             saddle = "baryonyx_saddle" },
    Brontosaurus   = { location = "@Dinos/Brontosaurus/Tame a Brontosaurus",     saddle = "bronto_saddle" },
    carno          = { location = "@Dinos/Carno/Tame a Carno",                   saddle = "carno_saddle" },
    chalicotherium = { location = "@Dinos/Chalicotherium/Tame a Chalicotherium", saddle = "chalicotherium_saddle" },
    daeodon        = { location = "@Dinos/Daeodon/Tame a Daeodon",               saddle = "daeodon_saddle" },
    direbear       = { location = "@Dinos/Dire Bear/Tame a Dire Bear",           saddle = "direbear_saddle" },
    direwolf       = { location = "@Dinos/Direwolf/Tame a Direwolf",             saddle = nil },
    kaprosuchus    = { location = "@Dinos/Kaprosuchus/Tame a Kaprosuchus",       saddle = "kaprosuchus_saddle" },
    mammoth        = { location = "@Dinos/Mammoth/Tame a Mammoth",               saddle = "mammoth_saddle" },
    quetzal        = { location = "@Dinos/Quetzal/Tame a Quetzal",               saddle = "quetzal_saddle" },
    sarco          = { location = "@Dinos/Sarco/Tame a Sarco",                   saddle = "sarco_saddle" },
    stegosaurus    = { location = "@Dinos/Stego/Tame a Stego",                   saddle = "stegosaurus_saddle" },
    terror_bird    = { location = "@Dinos/Terrorbird/Tame a Terrorbird",         saddle = "terrorbird_saddle" },
    Triceratops    = { location = "@Dinos/Triceratops/Tame a Triceratops",       saddle = "triceratops_saddle" },
    woolly_rhino   = { location = "@Dinos/Woolly Rhino/Tame a Woolly Rhino",     saddle = "woolly_rhino_saddle" }
}

function MediumFightTames()
    for _, tame in pairs(MEDIUM_FIGHT_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end
--========================================================================

--========================================================================
--Strong Fight Tames
STRONG_FIGHT_TAMES_LIST = {
    rex           = { location = "@Dinos/Rex/Tame a Rex",                     saddle = "rex_saddle" },
    rhyniognatha  = { location = "@Dinos/Rhyniognatha/Tame a Rhyniognatha",   saddle = "rhyniognatha_saddle" },
    spino         = { location = "@Dinos/Spino/Tame a Spino",                 saddle = "spino_saddle" },
    therizinosaur = { location = "@Dinos/Therizinosaur/Tame a Therizinosaur", saddle = "therizinosaur_saddle" },
    thylacoleo    = { location = "@Dinos/Thylacoleo/Tame a Thylacoleo",       saddle = "thylacoleo_saddle" },
    -- titanosaur    = { location = "@Dinos/Titanosaur/Tame a Titanosaur",       saddle = "titanosaur_saddle" },
    yutyrannus    = { location = "@Dinos/Yutyrannus/Tame a Yutyrannus",       saddle = "yutyrannus_saddle" }
}

function StrongFightTames()
    for _, tame in pairs(STRONG_FIGHT_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end
--========================================================================

--========================================================================
--Insane Fight Tames
INSANE_FIGHT_TAMES_LIST = {
    carcharodontosaurus = { location = "@Dinos/Carcharodontosaurus/Tame a Carcharodontosaurus", saddle = "carchardontosaurus_saddle" },
    giganotosaurus      = { location = "@Dinos/Giganotosaurus/Tame a Giganotosaurus",          saddle = "giganotosaurus_saddle" }
}

function InsaneFightTames()
    for _, tame in pairs(INSANE_FIGHT_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end
--==========================================================================

--==========================================================================
--Cave Tames
STANDARD_CAVE_TAMES_LIST = {
    sabertooth = { location = "@Dinos/Sabertooth/Tame a Sabertooth", saddle = "sabertooth_saddle" },
    baryonyx   = { location = "@Dinos/Baryonyx/Tame a Baryonyx",     saddle = "baryonyx_saddle" },
    direwolf   = { location = "@Dinos/Direwolf/Tame a Direwolf",     saddle = nil },
    raptor     = { location = "@Dinos/Raptor/Tame a Raptor",         saddle = "raptor_saddle" },
    thylacoleo = { location = "@Dinos/Thylacoleo/Tame a Thylacoleo", saddle = "thylacoleo_saddle" }
}

IMMUNE_TAMES_LIST = {
    beelzebufo = { location = "@Dinos/Beelzebufo/Tame a Beelzebufo", saddle = "beelzebufo_saddle" },
    baryonyx   = { location = "@Dinos/Baryonyx/Tame a Baryonyx",     saddle = "baryonyx_saddle" }
}

STRONG_TAMES_LIST = {
    allosaurus = { location = "@Dinos/Allosaurus/Tame a Allosaurus", saddle = "allosaurus_saddle" },
    thylacoleo = { location = "@Dinos/Thylacoleo/Tame a Thylacoleo", saddle = "thylacoleo_saddle" },
    yutyrannus = { location = "@Dinos/Yutyrannus/Tame a Yutyrannus", saddle = "yutyrannus_saddle" }
}

SWAMP_RIVER_TAMES_LIST = {
    sarco      = { location = "@Dinos/Sarco/Tame a Sarco",           saddle = "sarco_saddle" },
    baryonyx   = { location = "@Dinos/Baryonyx/Tame a Baryonyx",     saddle = "baryonyx_saddle" },
    thylacoleo = { location = "@Dinos/Thylacoleo/Tame a Thylacoleo", saddle = "thylacoleo_saddle" }
}

function ImmuneTames()
    for _, tame in pairs(IMMUNE_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function StrongTames()
    for _, tame in pairs(STRONG_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function PackTames()
    for _, tame in pairs(SWAMP_RIVER_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function UpperSouthTames()
    for _, tame in pairs(SWAMP_RIVER_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function MassiveTames()
    for _, tame in pairs(STANDARD_CAVE_TAMES_LIST) do
        if can_use_tame(tame) then return true end
    end
    return false
end

function CleverTames()
    return MassiveTames()
end

function HunterTames()
    return MassiveTames()
end

function DevourerTames()
    return MassiveTames()
end

function CentralTames()
    return MassiveTames()
end

function LowerSouthTames()
    return MassiveTames()
end
--========================================================================

--========================================================================
--Reptile List for eggs
REPTILE_LIST = {
    allosaurus          = { location = "@Dinos/Allosaurus/Tame a Allosaurus" },
    ankylosaurus        = { location = "@Dinos/Ankylosaurus/Tame a Ankylosaurus" },
    baryonyx            = { location = "@Dinos/Baryonyx/Tame a Baryonyx" },
    Brontosaurus        = { location = "@Dinos/Brontosaurus/Tame a Brontosaurus" },
    carbonemys          = { location = "@Dinos/Carbonemys/Tame a Carbonemys" },
    carcharodontosaurus = { location = "@Dinos/Carcharodontosaurus/Tame a Carcharodontosaurus" },
    carno               = { location = "@Dinos/Carno/Tame a Carno" },
    compy               = { location = "@Dinos/Compy/Tame a Compy" },
    dilophosaur         = { location = "@Dinos/Dilophosaur/Tame a Dilophosaur" },
    dimorphodon         = { location = "@Dinos/Dimorphodon/Tame a Dimorphodon" },
    diplodocus          = { location = "@Dinos/Diplodocus/Tame a Diplodocus" },
    gallimimus          = { location = "@Dinos/Gallimimus/Tame a Gallimimus" },
    giganotosaurus      = { location = "@Dinos/Giganotosaurus/Tame a Giganotosaurus" },
    iguanodon           = { location = "@Dinos/Iguanodon/Tame a Iguanodon" },
    kentrosaurus        = { location = "@Dinos/Kentrosaurus/Tame a Kentrosaurus" },
    megalania           = { location = "@Dinos/Megalania/Tame a Megalania" },
    megalosaurus        = { location = "@Dinos/Megalosaurus/Tame a Megalosaurus" },
    microraptor         = { location = "@Dinos/Microraptor/Tame a Microraptor" },
    morellatops         = { location = "@Dinos/Morellatops/Tame a Morellatops" },
    pachy               = { location = "@Dinos/Pachy/Tame a Pachy" },
    pachyrhinosaurus    = { location = "@Dinos/Pachyrhinosaurus/Tame a Pachyrhinosaurus" },
    parasaur            = { location = "@Dinos/Parasaur/Tame a Parasaur" },
    pegomastax          = { location = "@Dinos/Pegomastax/Tame a Pegomastax" },
    pteranodon          = { location = "@Dinos/Pteranodon/Tame a Pteranodon" },
    quetzal             = { location = "@Dinos/Quetzal/Tame a Quetzal" },
    raptor              = { location = "@Dinos/Raptor/Tame a Raptor" },
    rex                 = { location = "@Dinos/Rex/Tame a Rex" },
    spino               = { location = "@Dinos/Spino/Tame a Spino" },
    stegosaurus         = { location = "@Dinos/Stegosaurus/Tame a Stegosaurus" },
    tapejara            = { location = "@Dinos/Tapejara/Tame a Tapejara" },
    therizinosaur       = { location = "@Dinos/Therizinosaur/Tame a Therizinosaur" },
    thorny_dragon       = { location = "@Dinos/Thorny Dragon/Tame a Thorny Dragon" },
    Triceratops         = { location = "@Dinos/Triceratops/Tame a Triceratops" },
    troodon             = { location = "@Dinos/Troodon/Tame a Troodon" },
    wyvern              = { location = "@Dinos/Wyvern/Tame a Wyvern" },
    yutyrannus          = { location = "@Dinos/Yutyrannus/Tame a Yutyrannus" }
}

function reptile_tames()
    for _, tame in pairs(REPTILE_LIST) do
        if can_use_tame(tame) then
            return true
        end
    end
    return false
end

--========================================================================

--========================================================================
--Non Fighter Dinos
NON_FIGHTER_LIST = {
    achatina         = { location = "@Dinos/Achatina/Tame an Achatina" },
    archaeopteryx    = { location = "@Dinos/Archaeopteryx/Tame an Archaeopteryx" },
    compy            = { location = "@Dinos/Compy/Tame a Compy" },
    dilophosaur      = { location = "@Dinos/Dilophosaur/Tame a Dilophosaur" },
    dimetrodon       = { location = "@Dinos/Dimetrodon/Tame a Dimetrodon" },
    dimorphodon      = { location = "@Dinos/Dimorphodon/Tame a Dimorphodon" },
    diplocaulus      = { location = "@Dinos/Diplocaulus/Tame a Diplocaulus" },
    diplodocus       = { location = "@Dinos/Diplodocus/Tame a Diplodocus" },
    dodo             = { location = "@Dinos/Dodo/Tame a Dodo" },
    hesperornis      = { location = "@Dinos/Hesperornis/Tame a Hesperornis" },
    kentrosaurus     = { location = "@Dinos/Kentrosaurus/Tame a Kentrosaurus" },
    lystrosaurus     = { location = "@Dinos/Lystrosaurus/Tame a Lystrosaurus" },
    megalania        = { location = "@Dinos/Megalania/Tame a Megalania" },
    megaloceros      = { location = "@Dinos/Megaloceros/Tame a Megaloceros" },
    megalosaurus     = { location = "@Dinos/Megalosaurus/Tame a Megalosaurus" },
    mesopithecus     = { location = "@Dinos/Mesopithecus/Tame a Mesopithecus" },
    microraptor      = { location = "@Dinos/Microraptor/Tame a Microraptor" },
    onyc             = { location = "@Dinos/Onyc/Tame a Onyc" },
    otter            = { location = "@Dinos/Otter/Tame a Otter" },
    oviraptor        = { location = "@Dinos/Oviraptor/Tame a Oviraptor" },
    ovis             = { location = "@Dinos/Ovis/Tame a Ovis" },
    pachy            = { location = "@Dinos/Pachy/Tame a Pachy" },
    pachyrhinosaurus = { location = "@Dinos/Pachyrhinosaurus/Tame a Pachyrhinosaurus" },
    paracer          = { location = "@Dinos/Paracer/Tame a Paracer" },
    parasaur         = { location = "@Dinos/Parasaur/Tame a Parasaur" },
    pegomastax       = { location = "@Dinos/Pegomastax/Tame a Pegomastax" },
    phiomia          = { location = "@Dinos/Phiomia/Tame a Phiomia" },
    procoptodon      = { location = "@Dinos/Procoptodon/Tame a Procoptodon" },
    titanoboa        = { location = "@Dinos/Titanoboa/Tame a Titanoboa" },
    troodon          = { location = "@Dinos/Troodon/Tame a Troodon" }
}

function nonFighters()
    for _, tame in pairs(NON_FIGHTER_LIST) do
        if can_use_tame(tame) then
            return true
        end
    end
    return false
end

--========================================================================

--========================================================================

--========================================================================
--Tame Count
local function count_accessible_tames(lists)
    local seen_tames = {}
    local total_count = 0

    for _, tame_list in ipairs(lists) do
        for tame_key, tame in pairs(tame_list) do
            -- Deduplicate by creature key across all lists
            if not seen_tames[tame_key] then
                seen_tames[tame_key] = true
                if can_use_tame(tame) then
                    total_count = total_count + 1
                end
            end
        end
    end

    return total_count
end

function can_tame_count(required_amount)
    local all_tame_lists = {
        SHALLOW_TAMES_LIST,
        DEEP_TAMES_LIST,
        FLYER_LIST,
        BASIC_FIGHT_TAMES_LIST,
        MEDIUM_FIGHT_TAMES_LIST,
        STRONG_FIGHT_TAMES_LIST,
        INSANE_FIGHT_TAMES_LIST,
        REPTILE_LIST,
        NON_FIGHTER_LIST
    }

    return count_accessible_tames(all_tame_lists) >= tonumber(required_amount)
end

function can_tame_1()
  return can_tame_count(1)
end

function can_tame_5()
  return can_tame_count(5)
end

function can_tame_10()
  return can_tame_count(10)
end

function can_tame_20()
  return can_tame_count(20)
end

function can_tame_50()
  return can_tame_count(50)
end

--========================================================================
--Pelt Droppers
PELT_DROPPERS = {
    castoroides  = "@Dinos/Castoroides/Kill a Castoroides",
    direwolf     = "@Dinos/Direwolf/Kill a Direwold",
    direbear     = "@Dinos/Dire Bear/Kill a Dire Bear",
    mammoth      = "@Dinos/Mammoth/Kill a Mammoth",
    megatherium  = "@Dinos/Megatherium/Kill a Megatherium",
    ovis         = "@Dinos/Ovis/Kill a Ovis",
    otter        = "@Dinos/Otter/Kill a Otter",
    yutyrannus   = "@Dinos/Yutyrannus/Kill a Yutyrannus",
    woolly_rhino = "@Dinos/Woolly Rhino/Kill a Woolly Rhino",
}

function peltDino()
    for _, loc_path in pairs(PELT_DROPPERS) do
        local loc_obj = Tracker:FindObjectForCode(loc_path)
        if loc_obj then
            local is_accessible = loc_obj.AccessibilityLevel >= 3
            local is_cleared = loc_obj.AvailableChestCount < loc_obj.ChestCount
            if is_accessible or is_cleared then
                return true
            end
        end
    end
    return false
end

--========================================================================

--========================================================================
--Prime Meat Droppers
PRIME_DROPPERS = {
    allosaurus               = "@Dinos/Allosaurus/Kill an Allosaurus",
    argentavis               = "@Dinos/Argentavis/Kill an Argentavis",
    Brontosaurus             = "@Dinos/Brontosaurus/Kill a Brontosaurus",
    carno                    = "@Dinos/Carno/Kill a Carno",
    dimetrodon               = "@Dinos/Dimetrodon/Kill a Dimetrodon",
    diplodocus               = "@Dinos/Diplodocus/Kill a Diplodocus",
    giganotosaurus           = "@Dinos/Giganotosaurus/Kill a Giganotosaurus",
    hyaenodon                = "@Dinos/Hyaenodon/Kill a Hyaenodon",
    mammoth                  = "@Dinos/Mammoth/Kill a Mammoth",
    megalosaurus             = "@Dinos/Megalosaurus/Kill a Megalosaurus",
    paracer                  = "@Dinos/Paracer/Kill a Paracer",
    purlovia                 = "@Dinos/Purlovia/Kill a Purlovia",
    quetzal                  = "@Dinos/Quetzal/Kill a Quetzal",
    rex                      = "@Dinos/Rex/Kill a Rex",
    sarco                    = "@Dinos/Sarco/Kill a Sarco",
    spino                    = "@Dinos/Spino/Kill a Spino",
    therizinosaur            = "@Dinos/Therizinosaur/Kill a Therizinosaur",
    titanoboa                = "@Dinos/Titanoboa/Kill a Titanoboa",
}

function pmDino()
    for _, loc_path in pairs(PRIME_DROPPERS) do
        local loc_obj = Tracker:FindObjectForCode(loc_path)
        if loc_obj then
            local is_accessible = loc_obj.AccessibilityLevel >= 3
            local is_cleared = loc_obj.AvailableChestCount < loc_obj.ChestCount
            if is_accessible or is_cleared then
                return true
            end
        end
    end
    return false
end

--========================================================================

--========================================================================
--Prime Fish Droppers
PRIME_FISH_DROPPERS = {
    alpha_megalodon       = "@Dinos/Alpha Megalodon/Kill an Alpha Megalodon",
    alpha_tusoteuthis     = "@Dinos/Alpha Tusoteuthis/Kill an Alpha Tusoteuthis",
    dunkleosteus          = "@Dinos/Dunkleosteus/Kill a Dunkleosteus",
    leedsichthys          = "@Dinos/Leedsichthys/Kill a Leedsichthys",
    megalodon             = "@Dinos/Megalodon/Kill a Megalodon",
    sabertooth_salmon     = "@Dinos/Sabertooth Salmon/Kill a Sabertooth Salmon",
    tusoteuthis           = "@Dinos/Tusoteuthis/Kill a Tusoteuthis",
    }

function pfmDino()
    for _, loc_path in pairs(PRIME_FISH_DROPPERS) do
        local loc_obj = Tracker:FindObjectForCode(loc_path)
        if loc_obj then
            local is_accessible = loc_obj.AccessibilityLevel >= 3
            local is_cleared = loc_obj.AvailableChestCount < loc_obj.ChestCount
            if is_accessible or is_cleared then
                return true
            end
        end
    end
    return false
end
--========================================================================

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

function BowKO()
  if has("bow") and has("narcotic") and has("stone_arrow") and has("tranq_arrow") and CanUseMortar()
  then
    return true
  else
    return false
  end
end

function GhillieSet()
  if has("ghillie_mask") and has("ghillie_legs") and has("ghillie_gloves") and has("ghillie_chest") and has("ghillie_boots")
  then
    return true
  else
    return false
  end
end

function useChainsaw()
  if has("chainsaw") and CanUseFabricator()
  then
    return true
  else
    return false
  end
end

function useDrill()
  if has("drill") and CanUseFabricator()
  then
    return true
  else
    return false
  end
end

function craftRepellant()
  if CanUseMortar() and has("grow_crops") and has("repellant") and peltDino()
  then
    return true
  else
    return false
  end
end