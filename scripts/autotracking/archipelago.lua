-- this is an example/default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via their ids
-- it will also keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
-- if you run into issues when touching A LOT of items/locations here, see the comment about Tracker.AllowDeferredLogicUpdate in autotracking.lua
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
-- used for hint tracking to quickly map hint status to a value from the Highlight enum
-- HINT_STATUS_MAPPING = {}
-- if Highlight then
--  HINT_STATUS_MAPPING = {
--      [20] = Highlight.Avoid,
--      [40] = Highlight.None,
--      [10] = Highlight.NoPriority,
--      [0] = Highlight.Unspecified,
--      [30] = Highlight.Priority,
--  }
-- end

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

-- gets the data storage key for hints for the current player
-- returns nil when not connected to AP
-- function getHintDataStorageKey()
--  if AutoTracker:GetConnectionState("AP") ~= 3 or Archipelago.TeamNumber == nil or Archipelago.TeamNumber == -1 or Archipelago.PlayerNumber == nil or Archipelago.PlayerNumber == -1 then
--      if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
--          print("Tried to call getHintDataStorageKey while not connect to AP server")
--      end
--      return nil
--  end
--  return string.format("_read_hints_%s_%s", Archipelago.TeamNumber, Archipelago.PlayerNumber)
-- end

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

-- apply everything needed from slot_data, called from onClear
function apply_slot_data(slot_data)
    if slot_data['bundle_saddles'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_BS")
        if obj then
            obj.Active = (slot_data['bundle_saddles'] == true or slot_data['bundle_saddles'] == 1)
        end
    end

    if slot_data['free_starter_engrams'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_FSE")
        if obj then
            local is_active = (slot_data['free_starter_engrams'] == true or slot_data['free_starter_engrams'] == 1)
            obj.Active = is_active
            if is_active
            then
                local free_starter_items = {
                    "stone_hatchet",
                    "spear",
                    "campfire",
                    "thatch_foundation",
                    "waterskin"
                }
                for _, item_code in ipairs(free_starter_items) do
                    local item_obj = Tracker:FindObjectForCode(item_code)
                    if item_obj
                    then
                        item_obj.Active = true
                    end
                end
            end
        end
    end
end

-- called right after an AP slot is connected
function onClear(slot_data)
    -- use bulk update to pause logic updates until we are done resetting all items/locations
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
                        -- reset hosted item
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
    -- manually run snes interface functions after onClear in case we need to update them (i.e. because they need slot_data)
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
    end
    -- -- setup data storage tracking for hint tracking
    -- local data_strorage_keys = {}
    -- if PopVersion >= "0.32.0" then
    --     data_strorage_keys = { getHintDataStorageKey() }
    -- end
    -- subscribes to the data storage keys for updates
    -- triggers callback in the SetNotify handler on update
    -- Archipelago:SetNotify(data_strorage_keys)
    -- gets the current value for the data storage keys
    -- triggers callback in the Retrieved handler when result is received
    -- Archipelago:Get(data_strorage_keys)
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
                
                -- BUNDLE SADDLES INTERCEPTION
                local bundle_saddles_active = Tracker:FindObjectForCode("op_BS")
                if bundle_saddles_active and bundle_saddles_active.Active
                then
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
                    if LOCAL_ITEMS[item_code] then
                        LOCAL_ITEMS[item_code] = LOCAL_ITEMS[item_code] + 1
                    else
                        LOCAL_ITEMS[item_code] = 1
                    end
                else
                    if GLOBAL_ITEMS[item_code] then
                        GLOBAL_ITEMS[item_code] = GLOBAL_ITEMS[item_code] + 1
                    else
                        GLOBAL_ITEMS[item_code] = 1
                    end
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping item_table with no item_code"))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: skipping empty item_table"))
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    -- track local items via snes interface
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions for local item tracking here
    end
end


--called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
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
                        -- increment hosted item
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
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)