-- this is an example/default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via their ids
-- it will also keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
-- if you run into issues when touching A LOT of items/locations here, see the comment about Tracker.AllowDeferredLogicUpdate in autotracking.lua
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}
TRACKER_GROUPS = {}
TRACKER_GROUPS_ACTIVE = false
INCLUDED_LOCATIONS = {}

local function tame_sanity_location_enabled(location_id)
    local ts_obj = Tracker:FindObjectForCode("op_TS")

    if not ts_obj or not ts_obj.Active then
        return true
    end

    return INCLUDED_LOCATIONS[location_id] == true
end

local TAME_SANITY_IDS = {
    ["Tame: Achatina"]              = 8732001,
    ["Tame: Allosaurus"]            = 8732003,
    ["Tame: Angler"]                = 8732004,
    ["Tame: Ankylosaurus"]          = 8732005,
    ["Tame: Archaeopteryx"]         = 8732006,
    ["Tame: Argentavis"]            = 8732007,
    ["Tame: Arthropleura"]          = 8732008,
    ["Tame: Baryonyx"]              = 8732009,
    ["Tame: Basilosaurus"]          = 8732010,
    ["Tame: Castoroides"]           = 8732011,
    ["Tame: Dung Beetle"]           = 8732012,
    ["Tame: Gigantopithecus"]       = 8732013,
    ["Tame: Bronto"]                = 8732014,
    ["Tame: Carno"]                 = 8732015,
    ["Tame: Chalicotherium"]        = 8732016,
    ["Tame: Compsognathus"]         = 8732017,
    ["Tame: Daeodon"]               = 8732018,
    ["Tame: Dilophosaur"]           = 8732019,
    ["Tame: Dimetrodon"]            = 8732020,
    ["Tame: Dimorphodon"]           = 8732021,
    ["Tame: Diplodocus"]            = 8732022,
    ["Tame: Diplocaulus"]           = 8732023,
    ["Tame: Direbear"]              = 8732024,
    ["Tame: Direwolf"]              = 8732025,
    ["Tame: Dodo"]                  = 8732026,
    ["Tame: Doedicurus"]            = 8732027,
    ["Tame: Ichthyosaurus"]         = 8732028,
    ["Tame: Dunk"]                  = 8732029,
    ["Tame: Electrophorus"]         = 8732030,
    ["Tame: Equus"]                 = 8732031,
    ["Tame: Gallimimus"]            = 8732032,
    ["Tame: Giganotosaurus"]        = 8732033,
    ["Tame: Hesperornis"]           = 8732034,
    ["Tame: Hyaenodon"]             = 8732035,
    ["Tame: Ichthyornis"]           = 8732036,
    ["Tame: Iguanodon"]             = 8732037,
    ["Tame: Kairuku"]               = 8732038,
    ["Tame: Procoptodon"]           = 8732039,
    ["Tame: Kaprosuchus"]           = 8732040,
    ["Tame: Kentrosaurus"]          = 8732041,
    ["Tame: Liopleurodon"]          = 8732043,
    ["Tame: Lystrosaurus"]          = 8732044,
    ["Tame: Mammoth"]               = 8732045,
    ["Tame: Manta"]                 = 8732046,
    ["Tame: Megalodon"]             = 8732047,
    ["Tame: Megalania"]             = 8732049,
    ["Tame: Megalosaurus"]          = 8732050,
    ["Tame: Megatherium"]           = 8732051,
    ["Tame: Microraptor"]           = 8732052,
    ["Tame: Mesopithecus"]          = 8732053,
    ["Tame: Mosasaur"]              = 8732054,
    ["Tame: Moschops"]              = 8732055,
    ["Tame: Otter"]                 = 8732056,
    ["Tame: Oviraptor"]             = 8732057,
    ["Tame: Pachycephalosaurus"]    = 8732058,
    ["Tame: Pachyrhinosaurus"]      = 8732059,
    ["Tame: Parasaur"]              = 8732060,
    ["Tame: Paraceratherium"]       = 8732061,
    ["Tame: Pegomastax"]            = 8732062,
    ["Tame: Pelagornis"]            = 8732063,
    ["Tame: Phiomia"]               = 8732064,
    ["Tame: Plesiosaur"]            = 8732065,
    ["Tame: Pteranodon"]            = 8732066,
    ["Tame: Purlovia"]              = 8732067,
    ["Tame: Quetzal"]               = 8732068,
    ["Tame: Raptor"]                = 8732069,
    ["Tame: Rex"]                   = 8732070,
    ["Tame: Woolly Rhino"]          = 8732071,
    ["Tame: Sabertooth"]            = 8732072,
    ["Tame: Sarcosuchus"]           = 8732073,
    ["Tame: Pulmonoscorpius"]       = 8732074,
    ["Tame: Ovis"]                  = 8732075,
    ["Tame: Araneo"]                = 8732076,
    ["Tame: Spino"]                 = 8732077,
    ["Tame: Megaloceros"]           = 8732078,
    ["Tame: Stegosaurus"]           = 8732079,
    ["Tame: Tapejara"]              = 8732081,
    ["Tame: Terror Bird"]           = 8732082,
    ["Tame: Therizinosaurus"]       = 8732083,
    ["Tame: Thylacoleo"]            = 8732084,
    ["Tame: Titanoboa"]             = 8732086,
    ["Tame: Beelzebufo"]            = 8732087,
    ["Tame: Triceratops"]           = 8732088,
    ["Tame: Troodon"]               = 8732089,
    ["Tame: Carbonemys"]            = 8732090,
    ["Tame: Tusoteuthis"]           = 8732091,
    ["Tame: Yutyrannus"]            = 8732092,
    ["Tame: Onyc"]                  = 8732100,
    ["Tame: Giant Bee"]             = 8732101,
    ["Tame: Rhyniognatha"]          = 8732102,
    ["Tame: Carcharodontosaurus"]   = 8732103,
    ["Tame: Unicorn"]               = 8732104,
    ["Tame: Griffin"]               = 8732105,
    ["Tame: Mantis"]                = 8732106,
    ["Tame: Lymantria"]             = 8732107,
    ["Tame: Rock Elemental"]        = 8732108,
    ["Tame: Thorny Dragon"]         = 8732109,
    ["Tame: Vulture"]               = 8732110,
    ["Tame: Wyvern"]                = 8732111,
    ["Tame: Morellatops"]           = 8732112,
    ["Tame: Jerboa"]                = 8732113,
    ["Tame: Phoenix"]               = 8732114,
}

for key_name, id in pairs(TAME_SANITY_IDS) do
    local clean_name = key_name:lower():gsub("tame:%s*", ""):gsub("[%s%-]", "_")
    
    _G["tame_sanity_" .. clean_name .. "_enabled"] = function()
        return tame_sanity_location_enabled(id)
    end
end

local function food_sanity_location_enabled(location_id)
    local fs_obj = Tracker:FindObjectForCode("op_FS")

    if not fs_obj or not fs_obj.Active then
        return true
    end

    return INCLUDED_LOCATIONS[location_id] == true
end

local FOOD_SANITY_IDS = {
    citronal               = 8757300,
    longrass               = 8757301,
    rockarrot              = 8757302,
    savoroot               = 8757303,
    cooked_meat            = 8757304,
    cooked_meat_jerky      = 8757305,
    cooked_prime_meat      = 8757306,
    prime_meat_jerky       = 8757307,
    cooked_fish_meat       = 8757308,
    cooked_prime_fish_meat = 8757309,
    giant_bee_honey        = 8757310,
    rare_flower            = 8757311,
    rare_mushroom          = 8757312,
    plant_species_x_seed   = 8757313,
}

for name, id in pairs(FOOD_SANITY_IDS) do
    _G["food_sanity_" .. name .. "_enabled"] = function()
        return food_sanity_location_enabled(id)
    end
end

local function death_sanity_location_enabled(location_id)
    local ds_obj = Tracker:FindObjectForCode("op_DS")

    if not ds_obj or not ds_obj.Active then
        return true
    end

    return INCLUDED_LOCATIONS[location_id] == true
end

local DEATH_SANITY_IDS = {
    carnivore   = 8759000,
    herbivore   = 8759001,
    alpha       = 8759002,
    cold        = 8759003,
    heat        = 8759004,
    drowning    = 8759005,
    lava        = 8759006,
    falling     = 8759007,
    starvation  = 8759008,
    dehydration = 8759009,
}

for name, id in pairs(DEATH_SANITY_IDS) do
    _G["death_sanity_" .. name .. "_enabled"] = function()
        return death_sanity_location_enabled(id)
    end
end

-- resets an item to its initial state
function resetItem(item_code, item_type)
    local obj = Tracker:FindObjectForCode(item_code)
    if obj then
        item_type = item_type or obj.Type
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("resetItem: resetting item %s of type %s", item_code, item_type))
        end
        if item_type == "toggle" or item_type == "toggle_badged" then
            obj.Active = false
        elseif item_type == "progressive" or item_type == "progressive_toggle" then
            obj.CurrentStage = 0
            obj.Active = false
        elseif item_type == "consumable" then
            obj.AcquiredCount = 0
        elseif item_type == "custom" then
            -- your code for your custom lua items goes here
        elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("resetItem: tried to reset static item %s", item_code))
        elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format(
                "resetItem: tried to reset composite_toggle item %s but composite_toggle cannot be accessed via lua." ..
                "Please use the respective left/right toggle item codes instead.", item_code))
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("resetItem: unknown item type %s for code %s", item_type, item_code))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("resetItem: could not find item object for code %s", item_code))
    end
end

-- advances the state of an item
function incrementItem(item_code, item_type, multiplier)
    multiplier = multiplier or 1 -- Fallback to 1 if multiplier is nil
    local obj = Tracker:FindObjectForCode(item_code)
    if obj then
        item_type = item_type or obj.Type
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("incrementItem: code: %s, type %s, multiplier %s", item_code, item_type, tostring(multiplier)))
        end
        if item_type == "toggle" or item_type == "toggle_badged" then
            obj.Active = true
        elseif item_type == "progressive" or item_type == "progressive_toggle" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif item_type == "consumable" then
            local inc = obj.Increment or 1 -- Fallback to 1 if obj.Increment is nil
            obj.AcquiredCount = obj.AcquiredCount + (inc * multiplier)
        elseif item_type == "custom" then
            -- your code for your custom lua items goes here
        elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("incrementItem: tried to increment static item %s", item_code))
        elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format(
                "incrementItem: tried to increment composite_toggle item %s but composite_toggle cannot be access via lua." ..
                "Please use the respective left/right toggle item codes instead.", item_code))
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("incrementItem: unknown item type %s for code %s", item_type, item_code))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("incrementItem: could not find object for code %s", item_code))
    end
end

function incrementMappedItem(item_id)
    local mapping_entry = ITEM_MAPPING[item_id]
    if not mapping_entry then
        return
    end

    for _, item_table in pairs(mapping_entry) do
        if item_table then
            local item_code = item_table[1]
            local item_type = item_table[2]
            local multiplier = item_table[3] or 1
            if item_code then
                incrementItem(item_code, item_type, multiplier)
            end
        end
    end
end

-- apply everything needed from slot_data, called from onClear
function apply_slot_data(slot_data)
    TRACKER_GROUPS = {}
    INCLUDED_LOCATIONS = {}

    if type(slot_data["included_locations"]) == "table" then
        for _, location_id in ipairs(slot_data["included_locations"]) do
            local numeric_id = tonumber(location_id)
            if numeric_id then
                INCLUDED_LOCATIONS[numeric_id] = true
            end
        end
    end

    local engrams_per_item = tonumber(slot_data["engrams_per_item"]) or 1
    local tames_per_item = tonumber(slot_data["tames_per_item"]) or 1
    TRACKER_GROUPS_ACTIVE = engrams_per_item > 1 or tames_per_item > 1

    if TRACKER_GROUPS_ACTIVE and type(slot_data["tracker_groups"]) == "table" then
        for representative_id, member_ids in pairs(slot_data["tracker_groups"]) do
            TRACKER_GROUPS[tostring(representative_id)] = member_ids
        end
    end

    local engram_count_obj = Tracker:FindObjectForCode("engram_per_item")
    if engram_count_obj then
        engram_count_obj.AcquiredCount = engrams_per_item
    end

    local tame_count_obj = Tracker:FindObjectForCode("tame_per_item")
    if tame_count_obj then
        tame_count_obj.AcquiredCount = tames_per_item
    end

    if slot_data['bundle_saddles'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_BS")
        if obj then
            obj.Active = (slot_data['bundle_saddles'] == true or slot_data['bundle_saddles'] == 1)
        end
    end

    if slot_data['lock_taming'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_ST")
        if obj then
            obj.Active = (slot_data['lock_taming'] == true or slot_data['lock_taming'] == 1)
        end
    end

    if slot_data['lock_supply_crates'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_SC")
        if obj then
            obj.Active = (slot_data['lock_supply_crates'] == true or slot_data['lock_supply_crates'] == 1)
        end
    end

    if slot_data['death_milestones'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_DM")
        if obj then
            obj.Active = (slot_data['death_milestones'] == true or slot_data['death_milestones'] == 1)
        end
    end

    if slot_data['death_sanity'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_DS")
        if obj then
            local is_active = (tonumber(slot_data['death_sanity']) or 0) > 0
            obj.Active = is_active
        end
    end

    if slot_data['food_sanity'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_FS")
        if obj then
            obj.Active = (slot_data['food_sanity'] == true or slot_data['food_sanity'] == 1)
        end
    end

    if slot_data['tame_sanity'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_TS")
        if obj then
            obj.Active = (slot_data['tame_sanity'] == true or slot_data['tame_sanity'] == 1)
        end
    end

    if slot_data['free_starter_engrams'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_FSE")
        if obj then
            local is_active = (slot_data['free_starter_engrams'] == true or slot_data['free_starter_engrams'] == 1)
            obj.Active = is_active
            if is_active then
                local free_starter_items = {
                    "stone_hatchet",
                    "spear",
                    "campfire",
                    "thatch_foundation",
                    "waterskin"
                }
                for _, item_code in ipairs(free_starter_items) do
                    local item_obj = Tracker:FindObjectForCode(item_code)
                    if item_obj then
                        item_obj.Active = true
                    end
                end
            end
        end
    end
end

-- called right after an AP slot is connected
function onClear(slot_data)
    Tracker.BulkUpdate = true
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    CUR_INDEX = -1

    -- reset locations
    for _, mapping_entry in pairs(LOCATION_MAPPING) do
        for _, location_table in ipairs(mapping_entry) do
            if location_table then
                local location_code = location_table[1]
                if location_code then
                    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                        print(string.format("onClear: clearing location %s", location_code))
                    end
                    if location_code:sub(1, 1) == "@" then
                        local obj = Tracker:FindObjectForCode(location_code)
                        if obj then
                            obj.AvailableChestCount = obj.ChestCount
                            if obj.Highlight then
                                obj.Highlight = Highlight.None
                            end
                        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                            print(string.format("onClear: could not find location object for code %s", location_code))
                        end
                    else
                        local item_type = location_table[2]
                        resetItem(location_code, item_type)
                    end
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: skipping location_table with no location_code"))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping empty location_table"))
            end
        end
    end

    -- reset items
    for _, mapping_entry in pairs(ITEM_MAPPING) do
        for _, item_table in ipairs(mapping_entry) do
            if item_table then
                local item_code = item_table[1]
                local item_type = item_table[2]
                if item_code then
                    resetItem(item_code, item_type)
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: skipping item_table with no item_code"))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping empty item_table"))
            end
        end
    end
    
    apply_slot_data(slot_data)
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
    end
    
    Tracker.BulkUpdate = false
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end

    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index
    local mapping_entry = ITEM_MAPPING[item_id]
    if not mapping_entry then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end

    for _, item_table in pairs(mapping_entry) do
        if item_table then
            local item_code = item_table[1]
            local item_type = item_table[2]
            local multiplier = item_table[3] or 1
            if item_code then
                incrementItem(item_code, item_type, multiplier)

                local bundle_saddles_active = Tracker:FindObjectForCode("op_BS")
                if bundle_saddles_active and bundle_saddles_active.Active then
                    local tame_to_saddle_map = {
                        ["phiomia"] = "phiomia_saddle",
                        ["parasaur"] = "parasaur_saddle",
                        ["ichthyosaurus"] = "ichthyosaurus_saddle",
                        ["pachy"] = "pachy_saddle",
                        ["raptor"] = "raptor_saddle",
                        ["iguanodon"] = "iguanodon_saddle",
                        ["triceratops"] = "triceratops_saddle",
                        ["beelzebufo"] = "beelzebufo_saddle",
                        ["terrorbird"] = "terrorbird_saddle",
                        ["equus"] = "equus_saddle",
                        ["pachyrhinosaurus"] = "pachyrhinosaurus_saddle",
                        ["pulmonoscorpius"] = "pulmonoscorpius_saddle",
                        ["carbonemys"] = "carbonemys_saddle",
                        ["megaloceros"] = "megaloceros_saddle",
                        ["gallimimus"] = "gallimimus_saddle",
                        ["stegosaurus"] = "stegosaurus_saddle",
                        ["doedicurus"] = "doedicurus_saddle",
                        ["manta"] = "manta_saddle",
                        ["paracer"] = "paracer_saddle",
                        ["direbear"] = "direbear_saddle",
                        ["diplodocus"] = "diplodocus_saddle",
                        ["pteranodon"] = "pteranodon_saddle",
                        ["sarco"] = "sarco_saddle",
                        ["ankylosaurus"] = "ankylosaurus_saddle",
                        ["mammoth"] = "mammoth_saddle",
                        ["araneo"] = "araneo_saddle",
                        ["dunkleosteus"] = "dunkleosteus_saddle",
                        ["kaprosuchus"] = "kaprosuchus_saddle",
                        ["pelagornis"] = "pelagornis_saddle",
                        ["baryonyx"] = "baryonyx_saddle",
                        ["sabertooth"] = "sabertooth_saddle",
                        ["woollyrhino"] = "woollyrhino_saddle",
                        ["thylacoleo"] = "thylacoleo_saddle",
                        ["chalicotherium"] = "chalicotherium_saddle",
                        ["carno"] = "carno_saddle",
                        ["tapejara"] = "tapejara_saddle",
                        ["daeodon"] = "daeodon_saddle",
                        ["allosaurus"] = "allosaurus_saddle",
                        ["arthropluera"] = "arthropluera_saddle",
                        ["procoptodon"] = "procoptodon_saddle",
                        ["basilosaurus"] = "basilosaurus_saddle",
                        ["argentavis"] = "argentavis_saddle",
                        ["bronto"] = "bronto_saddle",
                        ["castoroides"] = "castoroides_saddle",
                        ["therizinosaur"] = "therizinosaur_saddle",
                        ["rex"] = "rex_saddle",
                        ["spino"] = "spino_saddle",
                        ["plesiosaur"] = "plesiosaur_saddle",
                        ["quetzal"] = "quetzal_saddle",
                        ["tusoteuthis"] = "tusoteuthis_saddle",
                        ["megalosaurus"] = "megalosaurus_saddle",
                        ["mosasaur"] = "mosasaur_saddle",
                        ["giganotosaurus"] = "giganotosaurus_saddle",
                        ["megatherium"] = "megatherium_saddle",
                        ["yutyrannus"] = "yutyrannus_saddle",
                        ["megalania"] = "megalania_saddle",
                        ["carcharodontosaurus"] = "carcharodontosaurus_saddle",
                        ["rhyniognatha"] = "rhyniognatha_saddle"
                    }

                    if tame_to_saddle_map[item_code] then
                        local corresponding_saddle_code = tame_to_saddle_map[item_code]
                        local saddle_obj = Tracker:FindObjectForCode(corresponding_saddle_code)
                        if saddle_obj then
                            saddle_obj.Active = true
                            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                                print(string.format("Bundle Saddles: Automatically activated %s because player received %s", corresponding_saddle_code, item_code))
                            end
                        end
                    end
                end

                if is_local then
                    LOCAL_ITEMS[item_code] = (LOCAL_ITEMS[item_code] or 0) + 1
                else
                    GLOBAL_ITEMS[item_code] = (GLOBAL_ITEMS[item_code] or 0) + 1
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping item_table with no item_code"))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: skipping empty item_table"))
        end
    end

    if TRACKER_GROUPS_ACTIVE then
        local grouped_members = TRACKER_GROUPS[tostring(item_id)]
        if grouped_members then
            for _, member_id in ipairs(grouped_members) do
                incrementMappedItem(member_id)
            end
        end
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions for local item tracking here
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    
    local mapping_entry = LOCATION_MAPPING[location_id]
    if not mapping_entry then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onLocation: could not find location mapping for id %s", location_id))
        end
        return
    end
    
    for _, location_table in pairs(mapping_entry) do
        if location_table then
            local location_code = location_table[1]
            if location_code then
                local obj = Tracker:FindObjectForCode(location_code)
                if obj then
                    if location_code:sub(1, 1) == "@" then
                        obj.AvailableChestCount = obj.AvailableChestCount - 1
                    else
                        local item_type = location_table[2]
                        local multiplier = location_table[3] or 1
                        incrementItem(location_code, item_type, multiplier)
                    end
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onLocation: could not find object for code %s", location_code))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onLocation: skipping location_table with no location_code"))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onLocation: skipping empty location_table"))
        end
    end
end

Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
Archipelago:AddRetrievedHandler("retrieved handler", onDataStorageUpdate)
Archipelago:AddSetReplyHandler("set reply handler", onDataStorageUpdate)