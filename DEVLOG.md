# Development Log

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

the subdivided ico sphere lends itself perfectly to a game played on a spherical, (almost) hexagonal grid.
