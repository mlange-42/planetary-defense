# Development Log

## 2022/01/01 -- Usability improvements

[v0.2.0]

Worked on improving accessibility through more information provided to the player.

Given the new major features finances and flow visualization, as well as the improved accessibility, it is time for release v.0.2.0.

### GUI improvements

* Add keyboard shortcuts for all buttons
* Tooltips with description, cost and requirements for everything that can be built (except cities)
* Information about reason on failed operations (e.g. not enough money)
* In-game settings for visibility of city labels, land use and roads
* Rework save/quit menu, add quit conformation
* Fullscreen option in main menu
* Rework city production panel (incl. tooltips)

### Further changes

* Slightly increased camera FOV to keep horizon in sight

### Bug fixes

* Fix saving city resource conversion (breaks save-game compatibility)

## 2021/12/30 -- Finances, tiles, information

[ba9e56d]

Introduced finances, several features to visualize what is going on, and tile map-like textures.

What's new:

* Introduced finances: taxes, budget, build and maintainance costs
* Visualization of flows and (potential) production/consumption
* Configurable planet generation: size, amount of water, humidity, temperature
* Tile texture on planet, with new geometry generation

![Screenshot](https://user-images.githubusercontent.com/44003176/147794302-35d259bf-3b86-4913-ae50-d8ca0b22ed0e.png)

*Screenshot showing the end-to-end flow visualization*

### Finances

Each turn, taxes flow into the budget, calculated `t * total production`. `t` is currently 1.0.

Build costs:

* City: 100
* Port: 50
* Road: 5 per tile

Maintenance costs:
* Road: 0.5 per tile
* Transport: 0.05 per tile and unit

### Visualization

The player can now much better judge what is going on.
End-to-end flows between cities can be visualized per commodity.
Further, Potential production and consumption, as well as actual production, are shown in the flows view.

Generally, this allows the player to find out about needs for production, as well as the reasons for traffic flows.

### Planet generation settings

When generating a planet, the player can configure size, height profile and climate variables.
Settings are realized through pre-defined interpolation curves.

### Tiles and geometry

Before, the geometry resembled the navigation mesh 1:1 (except sea level...).
This allows for color transitions between nodes, but not for tile-like texturing.

Geometry/mesh generation was changed to create hexagonal (and 12 pentagonal) areas around nodes.

The below ASCII art shows the old geometry (`*`), with the nodes of the new geometry denoted by `+`.

```
        *-----------*
       / \         / \
      /   \   +   /   \
     /     \     /     \
    /   +   \   /   +   \
   /         \ /         \
  *-----------+-----------*
   \         / \         /
    \   +   /   \   +   /
     \     /     \     /
      \   /   +   \   /
       \ /         \ /
        *-----------*
```

Each of the new triangles is UV-mapped to a texture atlas.

```
+-----+---
|  ,-'| ,-
|*    |*
|  `-.| `-
+-----+---
|     |
```

### Further changes

* Camera tilt depending on height
* Automatic city names
* Enhanced city labels
* Collision shape now follows sea level instead of ocean floor
* Several UI tweaks

### Bug fixes

* Block flag was not removed when removing roads ([#41])
* Do not build port on right-click [#56]

## 2021/12/28 -- Save/load games, binary releases

[v0.1.0]

* Implemented saving and loading of games (and the bare planet)
* Set up binary releases for Linux and Windows (MacOS requires some more work, see #36)

## 2021/12/27 -- City-centric Economy implemented

Over the past days, I implemented the plan from the previous entry.

![Screenshot](https://user-images.githubusercontent.com/44003176/147424375-ce1bc029-68b8-47c7-9ea0-794029d98ae3.png)

### Planet generation

* Ported the complete planet generator to Rust
* Extended the planet generator to create precipitation using noise
* Derive temperature from latitude and altitude
* Derive vegetation zones (see below) from temperature and precipitation

```
    Precipitation
     ^             .- Tundra         .- Subtropical Forest
1.0  |-----------+-+-----+---------+-+-------+
     |           | |     |         | |       |
     |           | |     |         | |       |
     |           | |     |         | |       |
     |           | |     |         | |       |
     |           | |Taiga|Temperate| | Trop. |
     |           | |     | Forest  | |Forest |
     |           | |     |         | |       |
     |           | |     |         | |       |
     |           | |     |         | |       |
     |  Glacier  | |     |         | |       |
     |           | |-----+---------+-+-------+.- Steppe
0.4  |           | |-------------------------+
     |           | |                         |
     |           | |                         |
     |           | |                         |
     |           | |          Desert         |
     |           | |                         |
     |           | |                         |
     |           | |                         |
0.0  +-----------+-+-----+---------+---------+--->
    0.0         0.3     0.5       0.75      1.0
                    Temperature
```
*Water is every tile with elevation < 0*

### Commodities, vegetation and land use types

Land use is restricted to city surroundings, and to certain vegetation types.
Land use types have a certain worker requirement per tile, and output amounts may vary between vegetation types

Commodities:

* Food (F)
* Resources (R)
* Products (R)

Vegetation:

* VEG_DESERT
* VEG_GLACIER
* VEG_TUNDRA
* VEG_TAIGA
* VEG_STEPPE
* VEG_TEMPERATE_FOREST
* VEG_SUBTROPICAL_FOREST
* VEG_TROPICAL_FOREST
* VEG_WATER

Land use:

* LU_CROPS (1 worker)
* LU_FOREST (1 worker)
* LU_FACTORY (3 workers)
* LU_FISHERY (1 worker)

|           | Crops | Forest | Fishery | Factory |
|-----------|-------|--------|---------|---------|
| Desert    |       |        |         |  5R->5P |
| Glacier   |       |        |         |         |
| Tundra    |       |        |         |  5R->5P |
| Taiga     |       |     1R |         |  5R->5P |
| Steppe    |    1F |        |         |  5R->5P |
| Temp. f.  |    2F |     2R |         |  5R->5P |
| Subtr. f. |    2F |     1R |         |  5R->5P |
| Trop. f   |    1F |     3R |         |  5R->5P |
| Water     |       |        |     2F* |  5R->5P |

*\* port required in the city*

### Cities

Cities are now the primary game entity. Everything else (except roads) is associated to a particular city.

Each city has an associated area of variable radius (areas may overlap!).
Within this area, land us types can be assigned according the city's available workers and vegetation type restrictions.
Further, facilities can be placed in this area (currently only ports).

Each worker that does not produce food requires one unit of food per turn.
Workers are processed by random tile order, and only those for which sufficient food was supplied will produce anything.

Each two workers "want" one unit of products per turn.
If all workers were supplied with food, a new free worker spawns with a probability proportional to the share of products requirement satisfied.

Each city can automatically assign workers to new land use.
Distribution of workers is governed by commodity weights that can be adjusted by the user foreach city individually.
So e.g., the user can set that 50% of the workers should produce food, 20% should produce resources, etc.

When more the 50% of the city's area is used, the city radius increases by one tile.

### Ports

Ports allow "roads" to interface between land and water.

```
Water  |---- Road
 ~   ~ | ~   ~
   ~  (#)--- Port
=======|======= Coast
       |
       |---- Road
Land
```

Further, ports allow for fishery as land use of the city.

### GUI Finite State Machine

Each GUI state (like editing roads, founding, or editing cities) now is a state in an FSM, and has its complete own GUI and behaviour.

This way, editing of cities (assigning land use and weights) is nicely isolated from the remaining UI.

## 2021/12/20 -- City-centric Economy

The next iteration will be to try an economy where everything is tied to cities/settlements.

Starting with a planet with 40k nav nodes (corresp. 200x200 square map), cities incl. surroundings are expected to have a radius of up to more than 10 cells. Given the large number of cells to be managed per settlement, we will take a semi-automatic approach.

The player will be able to decide on the share of the population working in each sector (resources, production, food, [energy?]). The exact allocation of land uses to cells is automated, but the player can change allocations.

Planet vertices need either a property like "landscape type", or underlying properties like "temperature" and "precipitation". Further, mineral resources are distributed over the planet. Based in resources and landscape type, the commodities "food", "resources" and "energy" can be produced with:

* different output per area
* different labour/population requirements
* different investment costs?

E.g. type "temperate forest" with "lignite deposit" could be suitable for either:

* 2 food per cell, 2 pop (crop farming)
* 1 food per cell, 1 pop (pastoral farming)
* 1 resource per cell, 1 pop (forestry; non-exhaustible)
* 5 resources per cell, 3 pop (lignite mining; exhaustible)

Roads will need to connect cities, but not individual productive cells. However, the output of cells (or the general possibility to assign usage) may depend on the distance to the network.

### TODOs

* Restructure planet generator:
   * Primary output: vertices with properties, edges (i.e. network links)
   * Secondary output: UV-mapped mesh
   * To use tiled textures (hexes), the geometry needs one more subdivision than the nav mesh (7 and 6 resp., for the underlying setup)
* Add a simple "climate model", i.e. add moisture/precipitation to generate landscape types
   * Will start with simplex noise; simple model with air flows may come later
* Given the above points: port the generator to Rust?

### Questions

* In which technological state does the game start? Are we...
   * ...intelligent live that emerged in the planet, and have to work up the technology tree?
   * ...something like shipwreck people stranded on that planet?
   * ... colonists with a connection to the outer world?

## 2021/12/19 -- Network and Facilities on Planet

### Progress

* Implement building roads and facilities on planet map
* Calculate flows using stochastic flow solver
* Visualize flows as color scale on network
* Info panel for inspecting facility in/out flows
* Add option for bi-directional version (retour also uses up capacity)

### Next step

* Implement intersection-free networks through additional network-specific node ids
   * Will allow for roads, railways, power lines, etc. in the same network
   * Requires special facilities (e.g. freight yards) as interface

## 2021/12/18 -- Transport Flow Experiments

### Progress

* Researched network flow algorithms - quite complicated matter
* Experiments with min cost max flow using Network Simplex algorithm from `graph_rs` [#2](https://github.com/mlange-42/planetary-defense/pull/2)
   * Not applicable for multiple commodities
   * Exact MCMF solution may not be desirable for a game - more even distribution to consumers required
* Implemented stochastic solution using Dijkstra from crate `pathfinding` ([#4](https://github.com/mlange-42/planetary-defense/pull/4))
   * Produces quite nice results, and has adjustable load dependency for pathfinding
   * Allows for multiple commodities and commodity conversion
   * Should have an eye on performance, as each unit is pathed individually

### Next Steps

* Design data structure for road network (draft in [#8](https://github.com/mlange-42/planetary-defense/pull/8)) and facilities (sources, sink, converters)
* Create UI for building networks and facilities

### Questions

* How to take into account transport costs?
   * Long transport routes should be associated to real costs. Options:
      * Reduce amount of arriving goods
      * Globally payed from "money" (is there such a thing? state budget?)
* How to structure the Godot side for the network and facilities like cities?
   * For performance and convenience, a bookkeeping/manager structure in addition to the scene tree will probably be required

## 2021/12/14 -- General Game Idea

A game between base- and city-building, taking place on one ore more spherical planets.

### Gamplay single planet

#### Resources

Resources can't be stored.

Production and processing are located in cities and on production sites. Resources must flow through the network to reach their destination. there may be a delay involved, or limited capacity (better!)

```
Food ----> Sustain cities

    On-site/environment
            '.
              :---> Electricity ----> Sustain cities (and structures?)
Resources --:'
             \                      .----> Build structures
              '---> Productivity --:
                                    '----> Sustain structures (and cities?)
                                     \
                                      '- - > Food
```

#### Entities

* Cities
* Resource sites
   * oil wells
   * power plants
* Traffic network/connections between Cities

Cities produce and process resources. Resources flow along network between cities.

Resources flow from resource-producing cities and sites to industrial cities, where they are processed.

Food flows between cities, primarily to resource cities.

Processed products cannot be accumulated. production output determined "building" capacities. Building something requires a certain level of production capacity, over a certain period of time.

Productivity is always locates in cities or sites, and needs to "diffuse" through the network. the network has a limited capacity per link.

##### Cities

Properties:

* population growth
* food production
* food consumption
* resource production
* industry (transforms resources --> to what?)
* electricity consumption

#### Transport network

Everything that can't be processed on site must flow through the network. There may be multiple networks, like power lines, roads, railroad (combine both?).

Network links have limited capacity (different upgrade levels may exist). Transport distance may or may not play a role in determining capacity.

Implementation is still unclear. Should it be a diffusive process, or should there be explicit connections (potentially all possible)? Diffusion probably requires iterative solving, connections means there can be a lot.

**Proposed algorithm 1:**

- Per production site, calculate inverse-distance-weighted distribution to all reachable target sites
- For each target, find the shortest path and add requested capacity to each edge along the path
- Do so for all production sites. Each edge now holds a sum of requested capacity. 
- Calculate "load factor" (percentage of demand satisfied) per edge
- Calculate transported amount per connection, based an lowest demand satisfied along path (i.e. bottleneck)

## 2021/12/12 -- Procedural Planet

Ported a Blender geometry nodes setup for generating procedural planets to Godot. Originally, just wanted to test new features of just released Blender 3.0.

![Screenshot](https://user-images.githubusercontent.com/44003176/146467231-0b694c98-a1d1-4d66-bc19-7e2f6cce6d61.png)

the subdivided ico sphere lends itself perfectly to a game played on a spherical, (almost) hexagonal grid.
