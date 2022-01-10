# Changelog

## [Unreleased]

### Added

* Show city growth and growth components in facility info panel
* Show conversion outome in land use info panel
* Land use "Irrigated crops"; allows cities in deserts
* Animated textures to visualize traffic on roads
* A different animated texture for sea lines

### Changed

* Prevents duplicate city names now
* Show city stats permanently when managing a city

### Bug fixes

## [v0.4.0]

### GUI Rework

A complete GUI rework with the following enhancements:

* Reworked, clearer layout
* Icons instead of text where adequate
* Most information now accessible in any GUI state (city stats, land use/vegetation information, production and finance stats)
* All modes accessible from everywhere (e.g. jump directly from city management to build mode)

### Added

* Cheat to schedule an attack on a city for the next turn
* Oil well land use for oil extraction on land
* Geometries for all land uses and facilities
* Pointer geometries and build indicator for setting land use in cities
* Highlight the currently selected city by differently colored outline
* Information on what is missing in messages for unsupplied facilities
* Notification when a resource deposit is depleted
* Sky color transition to blue when zooming in
* Independent visibility settings for city and defense ranges
* Animated turret rotation for air defense
* In-game options for fullscreen and zoom inversion
* Info panel to show possible land uses and facility/city stats, in any state, and build costs when building
* Indicate defense supply by range color

### Changed

* Moved the next turn button to the top-level GUI to make it accessible from everywhere
* Keep selected tool when switching between cities in city management
* Draw outlines instead of only vertices for all ranges (build, city, air defense)
  * Even draw bands with alpha gradient
* Increase resource amounts in deposits
* Make starting up growth and production easier:
  * Reduce number of workers for factory to 2
  * Let cities grow up to 5 without requiring products
* Reduced maintenance costs for ports, air defense, roads and transport
* Reduced basic city growth probability from 25% to 20%
* City supply state indicated by icon instead of color
* Message levels indicated by icon instead of color

### Bug fixes

* No more flickering city labels [#51]
* Cities now regrowth after complete wipe out [#119]
* City settings are now applied when switching between cities directly [#157]
* Update build range although mouse did not move since entering the state
