# Changelog

## [Unreleased]

### Added

* Provide different resource abundance settings for planet generation
* Sky dome to calculate and visualize communication coverage of certain facilities
* Ground station facility to generate coverage
* Resources are initially hidden, and only revealed through cities and coverage
* Flows view now allows to show network flow (by animation) for each commodity separately
* Button to toggle end-to-end flow visibility in flows view
* Make all message locations/cities clickable, underlined links
* Zoom to migration target by default, not source
* Outline shader for more toon-style graphics (custom inverse hull)
* In-game settings for antialiasing and outlines
* In build mode, the pointer now looks like the facility to build
* In build and city management mode, it is indicated whether building under the mouse is possible
* Coverage of facilities like the ground station is indicated ba a hovering circle
* Coverage is now elevation-dependent (like range)
* Road indicator changes color depending on whether building or clearing
* Animated water

### Changed

* Increased resource abundance for the default settings
* Allow building power lines over water
* Internal restructuring for integer commodity IDs
* Smaller power line geometries, lowered near facilities
* Changed renderer from GLES 3 to GLES 2

## [v0.5.0]

### Network modes

Added the possibility for different network modes (roads, rail, power lines, ...) and sub-types.
* Electricity as commodity, with power plants as producers and defenses as consumers
* Power lines to transport electricity
* Railways as high capacity network type
* Train stations as connectors between rail and road

### Added

* Show city growth and growth components in facility info panel
* Show conversion outcome in land use info panel
* Land use "Irrigated crops"; allows cities in deserts
* Animated textures to visualize traffic on roads
* A different animated texture for sea lines
* Display elevation in land use info
* Elevation-dependent range of defenses
* Elevation contours drawn on planet
* Slope limit for building roads - maximum elevation difference 200m
* Cliff vegetation type on steep and high ground
* Possibility to remove facilities
* Highways, railways, power lines and sea lines
* Power plant (non-city) and train station (city) facilities
* Solar plant land use
* Link type specific transport costs
* Cities can now be merged, taking over land use and facilities where possible
* Independent maximum slope for network types

### Changed

* Prevents duplicate city names now
* Show city stats permanently when managing a city
* Merge default and build GUI states; build is now the default
* Auto-select land use when clearing (with right-click), and nothing is selected
* Larger font for build cost info
* Draw road indicator using a band instead of a line, changed colors for better visibility
* Make build indicators smaller than actual buildings, to chow a change when actually building
* Ported road network data structure and logic to Rust
* No more migration to unconnected cities
* Air defenses now consume electricity instead of products
* Limit city growth by occupied area instead of population
* Auto-assign workers based on production rather than number of workers
* Display facility and total production stats using bar chart visualization

### Bug fixes

* Apply city settings on any change, not only on changing/leaving mode
* No more occlusion through transparent city label parts [#240]
* Correct handling of parallel edges in flow solver

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
