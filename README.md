# Planetary Defense

[![Tests](https://github.com/mlange-42/planetary-defense/actions/workflows/tests.yml/badge.svg)](https://github.com/mlange-42/planetary-defense/actions/workflows/tests.yml)

A game about planetary colonization and defense, with a focus on infrastructure and transport.

**[Download binaries](https://github.com/mlange-42/planetary-defense/releases)** for Linux and Windows.

**[Read the tutorial](docs/tutorial.md)** for getting started.

![Screenshot](https://user-images.githubusercontent.com/44003176/151182996-2f8e5e3f-0759-4ba5-937c-fe0d3ddc93a1.png)

Made with [Godot](https://godotengine.org/) and :crab: [Rust](https://rust-lang.org).

**[!] Work in progress (but playable) [!]**

## Game idea

The aim of this project is a large-scale, turn-based economy and transport simulation game with tower defense-like elements.

The player lands on an uninhabited planet and tries to build a well-fortified civilization defying planetary and extra-planetary threats.

Build and grow cities.
Manage their surrounding land use, to produce vitally needed food and resources.
Build a transport network or roads, railways, power lines and more to supply cities and military facilities.
Repel asteroids, alien invasions and other yet unknown dangers.

## Features

* Grand strategy sci-fi empire building and economy simulation
* Sophisticated procedural planet generator with elevation, climate and vegetation zones
* Configurable planet characteristics
* Macro-scale economy and logistics
* Cities with automated of manual land use management and production
* Multiple commodities: food, resourced, products and electricity
* No storage of commodities: everything must be produced just when needed (i.e. static state economy)
* Transport network with agent-based solver to mediate supply and demand on network with limited capacity
* Almost everything needs supplies, so transport infrastructure is critical

See the [DEVLOG](DEVLOG.md) for the general idea, as well as planned and implemented features.

### Multiplayer?

Currently, this is a single player game played against "the system".

Multiplayer is currently not planned due to limited developer capacities.
However, is not principally excluded for the future.

## Contributing

**Contributions and feedback welcome!**

For general feedback and feature ideas, please use the [Discussions](https://github.com/mlange-42/planetary-defense/discussions).

To report a bug, [open an issue](https://github.com/mlange-42/planetary-defense/issues).
