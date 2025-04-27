# Turn‑Based Game Engine Framework Overview

This document bootstraps the core architecture, modules, and conventions of the turn‑based game engine. Paste into a new chat to load context.

---

## Directory Structure
```
src/
└── engine/
    ├── core/
    │   ├── state/
    │   │   └── state.jl         # Game state & orchestration
    │   ├── action/
    │   │   └── action.jl        # Atomic action abstraction
    │   └── turn/
    └── service/
        ├── rng/
        │   └── rng.jl           # Random utilities
        ├── recursion/
        │   └── tree_cycle.jl    # Generic recursive tree engine
        ├── participant/
        │   └── participant.jl    # Player/team tree (uses TreeCycle)
        ├── phase/
        │   └── phase.jl          # Phase/subphase tree (uses TreeCycle)
        └── pipeline/
            └── pipeline.jl       # Composable step/flow engine
```

---

## Modules & Responsibilities

### 1. `State` (core/state/state.jl)
- Holds `player_group::Participant.Group{P}`, `phase_group::Phase.Group{Function}`, `data::Dict`, `rng::AbstractRNG`.
- Exposes constructors (`State`, `from_player_and_action`), getters (`player_current_get`, `phase_current_get`), mutators (`player_advance!`, `phase_advance!`), orchestration (`step_resolve!`, `state_reset!`).

### 2. `TreeCycle` (service/recursion/tree_cycle.jl)
- Defines `Node{T}`, `Leaf{T}`, `Group{T}` for recursive trees.
- Operations: `current_get!`, `advance!`, `reset!`.

### 3. `Participant` (service/participant/participant.jl)
- Re‑exports `TreeCycle` types specialized for player values.
- Provides `current_get!`, `advance!`, `reset!` for player/team traversal.

### 4. `Phase` (service/phase/phase.jl)
- Re‑exports `TreeCycle` types specialized for phase functions.
- Provides `current_get!`, `advance!`, `reset!` for phase/subphase traversal.

### 5. `RNG` (service/rng/rng.jl)
- Exports `AbstractRNG`, `default(...)`, `shuffle`, `sample`, `seed!`.
- Lightweight wrapper around Julia `Random`, supports optional seeding.

### 6. `Action` (core/action/action.jl)
- Abstract `Action` type and concrete `Function` wrapping `(state, rng)->Any` logic.
- Executes via `function_execute!`, noun‑verb naming.

### 7. `Pipeline` (service/pipeline/pipeline.jl)
- Composable `Step` (name, operation, condition, repetition, argument) and `Flow = TreeCycle.Group{Step}`.
- Executes atomic steps in tree order via `step_execute!` and `flow_execute!`.
- Supports static/dynamic args, fixed/dynamic loops, infinite nesting.

---

## Design Philosophy
1. **Minimal Core**: `State`, `Action`, `Turn` contain only essential fields and logic.  
2. **Single Responsibility**: Each module does one job—state holding, recursion, randomness, action, pipeline, etc.  
3. **Maximal Reuse**: Recursive logic centralized in `TreeCycle`; flows use that for both participants, phases, and pipelines.  
4. **Naming Conventions**:  
   - Modules & Types: PascalCase, minimal words (e.g. `Step`, `Flow`).  
   - Fields & Functions: noun_front + verb or adjective after, single form, `!` suffix for in‑place mutations.  
   - File names: snake_case matching module names (e.g. `pipeline.jl`).

---

## Quick‑Start Snippets

```julia
using RNG, Participant, Phase, Pipeline, Action, State

# Build a flat state
state = from_player_and_action(
    ["Alice","Bob"],               # 2 players
    [ (s,r)->println("draw",r),      # 2-phase: draw
      (s,r)->println("play",r) ]     #           play
)

# Define a pipeline of two steps
draw_step = Step(:draw, operation=(s,r)->println("Drawing for", player_current_get(s)))
play_step = Step(:play, operation=(s,r)->println("Playing for", player_current_get(s)))
flow = Flow([draw_step, play_step])

# Integrate into a phase
phase_flow = Step(:full_turn, operation=(s,r)->flow_execute!(flow, s, r))
state.phase_group = Flow([phase_flow])

# Run two cycles
flow_execute!(state.phase_group, state, state.rng)
flow_execute!(state.phase_group, state, state.rng)
```