# Changelog

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