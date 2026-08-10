-- this is an example/default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via their ids
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

-- used for hint tracking to quickly map hint status to a value from the Highlight enum
HINT_STATUS_MAPPING = {}
if Highlight then
	HINT_STATUS_MAPPING = {
		[20] = Highlight.Avoid,
		[40] = Highlight.None,
		[10] = Highlight.NoPriority,
		[0] = Highlight.Unspecified,
		[30] = Highlight.Priority,
	}
end

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

-- ==============================================================================
-- CUSTOM LOCATION MAPPINGS (LEVELS & BOSSES)
-- ==============================================================================

-- 1. Level Location Setup (8754000 to 8754103)
local LEVEL_BASE_ID = 8754000
local TOTAL_LEVEL_CHECKS = 104
local LEVEL_LOCATION_IDS = {}
for i = 0, TOTAL_LEVEL_CHECKS - 1 do
	table.insert(LEVEL_LOCATION_IDS, LEVEL_BASE_ID + i)
end

-- 2. Boss Location Setup (Maps Gamma/Beta/Alpha to 1 boss item code)
-- CHANGE ITEM CODES HERE if your items.json uses different codes
local BOSS_LOCATION_MAPPING = {
	-- Broodmother (Gamma, Beta, Alpha)
	[8750000] = "boss_broodmother",
	[8750010] = "boss_broodmother",
	[8750020] = "boss_broodmother",

	-- Megapithecus (Gamma, Beta, Alpha)
	[8750001] = "boss_megapithecus",
	[8750011] = "boss_megapithecus",
	[8750021] = "boss_megapithecus",

	-- Dragon (Gamma, Beta, Alpha)
	[8750002] = "boss_dragon",
	[8750012] = "boss_dragon",
	[8750022] = "boss_dragon",

	-- Overseer (Gamma, Beta, Alpha)
	[8750003] = "boss_overseer",
	[8750013] = "boss_overseer",
	[8750023] = "boss_overseer",
}

local BOSS_LOCATION_IDS = {}
for loc_id, _ in pairs(BOSS_LOCATION_MAPPING) do
	table.insert(BOSS_LOCATION_IDS, loc_id)
end

-- ==============================================================================
-- HELPER FUNCTIONS
-- ==============================================================================

function getHintDataStorageKey()
	if AutoTracker:GetConnectionState("AP") ~= 3 or Archipelago.TeamNumber == nil or Archipelago.TeamNumber == -1 or Archipelago.PlayerNumber == nil or Archipelago.PlayerNumber == -1 then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print("Tried to call getHintDataStorageKey while not connect to AP server")
		end
		return nil
	end
	return string.format("_read_hints_%s_%s", Archipelago.TeamNumber, Archipelago.PlayerNumber)
end

function resetItem(item_code, item_type)
	local obj = Tracker:FindObjectForCode(item_code)
	if obj then
		item_type = item_type or obj.Type
		if item_type == "toggle" or item_type == "toggle_badged" then
			obj.Active = false
		elseif item_type == "progressive" or item_type == "progressive_toggle" then
			obj.CurrentStage = 0
			obj.Active = false
		elseif item_type == "consumable" then
			obj.AcquiredCount = 0
		end
	end
end

function incrementItem(item_code, item_type, multiplier)
	local obj = Tracker:FindObjectForCode(item_code)
	if obj then
		item_type = item_type or obj.Type
		if item_type == "toggle" or item_type == "toggle_badged" then
			obj.Active = true
		elseif item_type == "progressive" or item_type == "progressive_toggle" then
			if obj.Active then
				obj.CurrentStage = obj.CurrentStage + 1
			else
				obj.Active = true
			end
		elseif item_type == "consumable" then
			obj.AcquiredCount = obj.AcquiredCount + obj.Increment * (multiplier or 1)
		end
	end
end

function apply_slot_data(slot_data)
	-- put any code here that slot_data should affect
end

-- ==============================================================================
-- AP HANDLERS & CALLBACKS
-- ==============================================================================

function onClear(slot_data)
	Tracker.BulkUpdate = true
	CUR_INDEX = -1

	-- Reset standard mapped locations
	for _, mapping_entry in pairs(LOCATION_MAPPING) do
		for _, location_table in ipairs(mapping_entry) do
			if location_table then
				local location_code = location_table[1]
				if location_code then
					if location_code:sub(1, 1) == "@" then
						local obj = Tracker:FindObjectForCode(location_code)
						if obj then
							obj.AvailableChestCount = obj.ChestCount
							if obj.Highlight then obj.Highlight = Highlight.None end
						end
					else
						resetItem(location_code, location_table[2])
					end
				end
			end
		end
	end

	-- Reset standard mapped items
	for _, mapping_entry in pairs(ITEM_MAPPING) do
		for _, item_table in ipairs(mapping_entry) do
			if item_table and item_table[1] then
				resetItem(item_table[1], item_table[2])
			end
		end
	end

	-- Reset custom items (Level consumable & Boss toggles)
	resetItem("level", "consumable")
	resetItem("boss_broodmother", "toggle")
	resetItem("boss_megapithecus", "toggle")
	resetItem("boss_dragon", "toggle")
	resetItem("boss_overseer", "toggle")

	apply_slot_data(slot_data)
	LOCAL_ITEMS = {}
	GLOBAL_ITEMS = {}

	local data_strorage_keys = {}
	if PopVersion >= "0.32.0" then
		data_strorage_keys = { getHintDataStorageKey() }
	end
	Archipelago:SetNotify(data_strorage_keys)
	Archipelago:Get(data_strorage_keys)
	Tracker.BulkUpdate = false
end

function onItem(index, item_id, item_name, player_number)
	if not AUTOTRACKER_ENABLE_ITEM_TRACKING or index <= CUR_INDEX then return end
	local is_local = player_number == Archipelago.PlayerNumber
	CUR_INDEX = index

	local mapping_entry = ITEM_MAPPING[item_id]
	if not mapping_entry then return end

	for _, item_table in pairs(mapping_entry) do
		if item_table and item_table[1] then
			incrementItem(item_table[1], item_table[2], item_table[3] or 1)
		end
	end
end

function onLocation(location_id, location_name)
	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then return end

	local mapping_entry = LOCATION_MAPPING[location_id]
	if not mapping_entry then return end

	for _, location_table in pairs(mapping_entry) do
		if location_table and location_table[1] then
			local location_code = location_table[1]
			local obj = Tracker:FindObjectForCode(location_code)
			if obj then
				if location_code:sub(1, 1) == "@" then
					obj.AvailableChestCount = obj.AvailableChestCount - 1
				else
					incrementItem(location_code, location_table[2])
				end
			end
		end
	end
end

-- Custom Callback: Handles Level checks
function onLevelLocation(location_id, location_name)
	local reached_level = (location_id - LEVEL_BASE_ID) + 2
	local level_item = Tracker:FindObjectForCode("level")
	if level_item and level_item.AcquiredCount < reached_level then
		level_item.AcquiredCount = reached_level
	end
end

-- Custom Callback: Handles Boss checks regardless of difficulty
function onBossLocation(location_id, location_name)
	local boss_code = BOSS_LOCATION_MAPPING[location_id]
	if boss_code then
		local boss_item = Tracker:FindObjectForCode(boss_code)
		if boss_item then
			boss_item.Active = true
		end
	end
end

function onDataStorageUpdate(key, value, oldValue)
	if key == getHintDataStorageKey() then
		onHintsUpdate(value)
	end
end

function onHintsUpdate(hints)
	if PopVersion < "0.32.0" or not AUTOTRACKER_ENABLE_LOCATION_TRACKING then return end
	local player_number = Archipelago.PlayerNumber
	local sections_to_update = {}
	for _, hint in ipairs(hints) do
		if hint.finding_player == player_number then
			updateHint(hint, sections_to_update)
		end
	end
	for location_code, highlight_code in pairs(sections_to_update) do
		local obj = Tracker:FindObjectForCode(location_code)
		if obj and obj.Highlight then
			obj.Highlight = highlight_code
		end
	end
end

function updateHint(hint, sections_to_update)
	local highlight_code = HINT_STATUS_MAPPING[hint.status]
	if not highlight_code then
		if hint.found == true then highlight_code = Highlight.None
		elseif hint.found == false then highlight_code = Highlight.Unspecified
		else return end
	end
	local mapping_entry = LOCATION_MAPPING[hint.location]
	if not mapping_entry then return end

	for _, location_table in pairs(mapping_entry) do
		if location_table and location_table[1] and location_table[1]:sub(1, 1) == "@" then
			local location_code = location_table[1]
			local existing = sections_to_update[location_code]
			if not existing or existing == Highlight.None or (existing < highlight_code and highlight_code ~= Highlight.None) then
				sections_to_update[location_code] = highlight_code
			end
		end
	end
end

-- ==============================================================================
-- REGISTER ARCHIPELAGO HANDLERS
-- ==============================================================================

Archipelago:AddClearHandler("clear handler", onClear)

if AUTOTRACKER_ENABLE_ITEM_TRACKING then
	Archipelago:AddItemHandler("item handler", onItem)
end

if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
	Archipelago:AddLocationHandler("location handler", onLocation)
	-- Add custom location listeners
	Archipelago:AddLocationHandler("level location handler", LEVEL_LOCATION_IDS, onLevelLocation)
	Archipelago:AddLocationHandler("boss location handler", BOSS_LOCATION_IDS, onBossLocation)
end

Archipelago:AddRetrievedHandler("retrieved handler", onDataStorageUpdate)
Archipelago:AddSetReplyHandler("set reply handler", onDataStorageUpdate)