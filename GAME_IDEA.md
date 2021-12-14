A game between base- and city-building, taking place on one ore more spherical planets.

## Gamplay single planet

### Resources

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

### Entities

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

#### Cities

Properties:

* population growth
* food production
* food consumption
* resource production
* industry (transforms resources --> to what?)
* electricity consumption

### Transport network

Everything that can't be processed on site must flow through the network. There may be multiple networks, like power lines, roads, railroad (combine both?).

Network links have limited capacity (different upgrade levels may exist). Transport distance may or may not play a role in determining capacity.

Implementation is still unclear. Should it be a diffusive process, or should there be explicit connections (potentially all possible)? Diffusion probably requires iterative solving, connections means there can be a lot.

**Proposed algorithm 1:**

- Per production site, calculate inverse-distance-weighted distribution to all reachable target sites
- For each target, find the shortest path and add requested capacity to each edge along the path
- Do so for all production sites. Each edge now holds a sum of requested capacity. 
- Calculate "load factor" (percentage of demand satisfied) per edge
- Calculate transported amount per connection, based an lowest demand satisfied along path (i.e. bottleneck)


