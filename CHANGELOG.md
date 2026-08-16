# Changelog

## [0.0.3] - Cave Logic Applied

### Fixed
- Functions for tier recognition in `logic.lua`. Now explorer notes will turn green when conditions are met

### Added
- Logic added for caves, including tames and equipment required in `logic.lua`
- Changed access rules for caves in `notes.json`

### Changed
- Removed Boss Kill Locations from `dinos.json`. Holograms are synced with `location_mapping.lua`

### TODO
- Give starter engrams when setting enabled
- Sync saddles to tames when saddles are bundled
- Work out a way for multiple engrams and tames when reward amount > 1

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