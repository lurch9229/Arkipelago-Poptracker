local variant = Tracker.ActiveVariantUID

--LOADED SCRIPTS
ScriptHost:LoadScript("scripts/logic.lua")
ScriptHost:LoadScript("scripts/autotracking.lua")

--LOAD ITEMS
Tracker:AddItems("items/items.json")


-- Open Maps, Then Layouts, Then Locations
Tracker:AddMaps("maps/maps.json")
Tracker:AddLayouts("layouts/tracker_standard.json")
Tracker:AddLocations("locations/dinos.json")
Tracker:AddLocations("locations/notes.json")
Tracker:AddLocations("locations/milestones.json")


