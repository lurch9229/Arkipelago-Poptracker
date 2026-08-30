# Changelog

## [0.0.7]

## Fixed
- `location_mapping.lua` now has the correct names for Ovis and Ichthornis
- `location_mapping.lua` now has explore regions (Not sure how I missed this previously)
- hosted items will now clear locations correctly (I Hope)

## Added
- Support for Note Sanity - The Tracker will now show which notes are checks if < max count
- `location_mapping.lua` now has autotracking done for Scorched Earth. SE is nearing completion and just needs logic
- `items.lua`
- More collect tasks (I think this is all of them for now)

## Changed
- Capitalization of some tame names
- Food, Tame and Note sanity icons are now static and can't be interacted with. Slot data determines the percentage or count and displays this on the icons
- Updated Island Map to have new collects
- foodsanity now has functions for each count rather than a global function. Now tracker will only show the collects you need to do when foodsanity < 100

## Todo
- Apply Logic for Collect and Explorer Notes once added to APWorld
- Finalise tracker for Scorched Earth

---

## [0.0.6.1]

## Fixed
- function names incorrect for some tame sanity calls `dinos.josn`
- restored commented item mapping for wooden club, slingshot and some SE items

## Added
- Some S+ engrams to bundles that were not in the APWorld originally
- Native support for Lethal's Reusables Mod

## Changed
- Explorer Notes now use the region they are contained in rather than just saying surface

## TODO
- Apply Logic for Milestones and Collects once added to APWorld

## [0.0.6] - Setting Support Phase 2

---

## Fixed
- Collect Bio Toxin now uses correct ref for Kill Cnidaria `milestone.json`
- Some ref were calling wrong locations `location_mapping.lua`
- Some logic using campfire was incorrect `milestones.json`

## Added
- Alpha Trophies For SE
- Support for Setting Engrams Per Item `archipelago.lua`
- Support for Setting Tames Per Item `archipelago.lua`
- Toggle for Tame and Crate Lock settings `archipelago.lua`
- New Milestone Locations `milestones.json`
- `items.json` updated with settings items
- Tame Logic now applied `dinos.json`
- Support for sanity options (food,tames,deaths) `archipelago.lua`
- Support for death milestones `archipelago.lua`
- Mapping for new collect tasks `location_mapping.lua`

## Changed
- Layouts to support new settings `tracker_standard.json`
- Collect Element reduced to x1 and x5 `milestones.json`
- Alpha Wyvern and Alpha Deathworm now have hosted items for their trophies `dinos.json`

## TODO
- Apply Logic for Milestones and Collects once added to APWorld

---

## [0.0.5] - More Scorched Earth Prep

## Fixed
- Explorer Notes in the Tek Cave now have correct logic `notes.json`
- References for tributes from dinos now have the correct format in `milestones.json`
- Cooking Pot was commented out in `item_mapping.lua`

## Added
- More Locations for Scorched Earth
- Final assets for SE
- `items.json` has everything needed for SE
- Added Support for S+/SS Structures (automatically applied) using `item_mapping.lua`
- Added Bundled Strutures (automatically applied) using `item_mapping.lua`
- `tracker_standard.json` layout changes for Scorched Earth

## Changed
- SE Map now has more collect icons as a few were missing
- Therizino is now captialized on item grid

## TODO
- Apply Tame Logic to The Island
- Finalize Logic for The Island Explorer Notes
- Create handling for player settings

---

## [0.0.4] - Setting Support Phase One

## Fixed
- Nothing needed to be fixed this version

## Added
- Items for Settings in `items.json`
- Functions for Bundled Saddles and Free Starter Engrams added to `archipelago.lua`
- Scorched Earth ~ Added Locations to `dinos.json` and `notes.json`
- Scorched Earth ~ Added map images and updated `maps.json`
- Scorched Earth ~ Started work on `tracker_standard.json` for SE layout

## Changed
- Itemgrid added to layout in `tracker_standard.json` for settings visual
- Updated version in `manifest.json`

## TODO
- Finish SE support
- Add support for more setting once Ghios adds them to slot_data
- Liase with Ghios  on a way to support > 1 location rewards

---

## [0.0.3] - Cave Logic Applied

### Fixed
- Functions for tier recognition in `logic.lua`. Now explorer notes will turn green when conditions are met

### Added
- Logic added for caves, including tames and equipment required in `logic.lua`
- Changed access rules for caves in `notes.json`
- Some base assets for future Scorched Earth support

### Changed
- Removed Boss Kill Locations from `dinos.json`. Holograms are synced with `location_mapping.lua`

### TODO
- Give starter engrams when setting enabled
- Sync saddles to tames when saddles are bundled
- Work out a way for multiple engrams and tames when reward amount > 1

---

## [0.0.2] - Finalised Autotracking

### Fixed
- Fixed missing file extension in script load call for `archipelago.lua`.
- Fixed `Multiplier` nil error handling in `archipelago.lua`.
- Fixed code for simple ammo in `items.json`.
- Fixed misnamed location names/keys across location/item mappings.
- Fixed script `init` where it was trying to read from an incorrect folder.

### Added
- Added correct format for consumable items in location mapping.
- Added support for extra loot crate types.

### Changed
- Moved boss trophy logic to hologram check (due to missing direct boss defeat checks).


### TODO
- Remove Boss Defeat locations

---

## [0.0.1] - Initial Release

### Added
- Initial commit for repository.