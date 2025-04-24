# Itera Project Summary

**Last Updated**: 2025-04-24 01:54

---

## ✅ Current Status

Itera is a modular turn-based game simulation framework written in Julia, currently structured around the card game *Dominion*. The architecture is designed to generalize across turn-based games (e.g. Pokémon Showdown, Magic: The Gathering, Slay the Spire, Civilization VI) via minimal but extensible modules.

---

## 🧩 Core Modules

| Module      | Description                                                                 |
|-------------|-----------------------------------------------------------------------------|
| `State`     | Manages game-wide and player-specific state.                                |
| `Turn`      | Encapsulates the logic for executing a single turn.                         |
| `Pipeline`  | Handles execution of atomic game steps with optional repetition.            |
| `Effect`    | Supports persistent game effects: Timed, Conditional, Event-based.          |
| `Choice`    | Provides strategy-based selection mechanisms for actions.                   |
| `Participant` | Manages player ordering and control.                                      |
| `Phase`     | Defines per-turn phases (e.g., Action, Buy).                                |
| `TreeCycle` | Circular linked list for traversing options or players.                     |

---

## 🚧 Implementation Phase

**Core system: ✅ Completed**
- `Effect`, `Pipeline`, `Turn`, `Choice` are now tested and stable.

**Scenario integration: ✅ In use**
- Dominion-specific scenarios validate chaining, conditional and event triggers.

**Tracker / Logger / Snapshot: 🔜 To be re-integrated**
- These are modular and scheduled for DSL integration phase.

---

## 🧠 Design Philosophy

| Principle              | Explanation                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| **Minimal Core**       | Only implement what's generalizable to most turn-based games.              |
| **Composable Modules** | Each concept (Turn, Step, Effect) can be plugged or replaced independently.|
| **State-Driven**       | All logic reads from and mutates a central `Game` object.                   |
| **Effect-Priority**    | Game effects are flushed pre/post steps and turns in a consistent lifecycle.|
| **Strategy-Agnostic**  | Decision logic (random, always, limited) is abstracted from mechanics.      |

---

## ✏️ Naming Conventions

- `add!`, `remove!`, `apply!`, `emit!` used for all stateful mutating operations.
- Abstract types use short generic names (`Base`, not `EffectBase`).
- Avoid full module prefixes in names unless ambiguity occurs.
- Hooks: `"on_" * stepname` convention used to trigger effects/events.

---

## 🔄 Suggested Native Enhancements

While most features can be added externally, the following may be worthwhile for native support:

- 🔁 **Step hook dispatching** (e.g. `before_step`, `after_step`)  
- 🧠 **Effect scoping per player / phase**  
- 🔀 **Rule queue / stack** for complex games like Magic  
- 🧩 **Custom flow interpreters** for Slay the Spire–style branching  
- 📦 **Plugin registration system** for user-defined modules  

---

## ✅ Summary

The framework is ready for:
- Full AI self-play
- Game-specific rulesets and strategy modules
- DSL-driven scenario definitions
- Frontend visualization support

Further development will focus on DSL integration and platformization.