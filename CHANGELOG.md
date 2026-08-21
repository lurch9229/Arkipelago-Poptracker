# Changelog

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

## Todo
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