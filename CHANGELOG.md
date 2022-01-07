# Changelog

## [Unreleased]

### Added

* Cheat to schedule an attack on a city for the next turn
* Oil well land use for oil extraction on land
* Geometries for all land uses and facilities
* Pointer geometries and build indicator for setting land use in cities
* Highlight the currently selected city by differently colored outline
* Information on what is missing in messages for unsupplied facilities
* Notification when aresource deposit is depleted
* Sky color transition to blue when zooming in
* Independent visibility settings for city and defense ranges

### Changed

* Moved the next turn button to the top-level GUI to make it accessible from everywhere
* Keep selected tool when switching between cities in city management
* Draw outlines instead of only vertices for all ranges (build, city, air defense)
  * Even draw bands with alpha gradient
* Increase resource amounts in deposits
* Make starting groth and production easier:
  * Reduce number of workers for factory to 2
  * Let cities grow up to 5 without requiring products
* Reduced maintenance costs for ports, air defense, roads and transport
* Reduced basic city growth probability from 25% to 20%

### Bug fixes

* No more flickering city labels [#51]
* Cities now regrowth after complete wipe out [#119]
