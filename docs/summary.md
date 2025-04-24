# Itera Project Summary

## 1. Project Overview

**Itera.jl** is a lightweight, extensible Julia framework for building turn‑based, card/strategy games (e.g., Dominion, Pokémon, Sakura Arms). It provides:

- **Core engine**: generic game state and turn driver
- **Pipeline**: composable effects orchestration (conditional, looping, dynamic args)
- **Choice**: pluggable decision strategies via a registry
- **Plugins**: game‑specific card/rules modules
- **Utils**: resource loading (e.g., PNG assets)

Designed for *modularity*, *testability*, and *AI compatibility*.

## 2. Key Goals

1. **Generalise** common mechanics across card/strategy games
2. **Decouple** core engine, effects orchestration, and decision logic
3. **Enable** plugin-driven game definitions (cards, rules)
4. **Expose** clear hooks for AI/self‑play and DSL/AST layers
5. **Support** incomplete information, randomness, cross‑turn effects

## 3. Project Architecture

```
Itera.jl
├── docs/                  # Documentation & Quick Start
├── src/
│   ├── Core/
│   │   ├── state.jl       # State template & keyword constructor
│   │   ├── action.jl      # Abstract Action type & constructors
│   │   └── turn.jl        # run_turn! orchestration
│   │
│   ├── Pipeline/
│   │   ├── step.jl        # Step struct (op, args, condition, loop)
│   │   ├── flow.jl        # Flow struct (sequence of Steps)
│   │   └── run.jl         # run_pipeline! implementation
│   │
│   ├── Choice/
│   │   ├── context.jl     # ChooseCtx & ChooseRes types
│   │   ├── registry.jl    # strategy registration (macros)
│   │   └── resolve.jl     # choose!(ctx) strategy resolver
│   │
│   ├── Utils/
│   │   └── assets.jl      # PNG/image loader & cache
│   │
│   └── Plugins/
│       └── Dominion/      # Example game plugin (cards, rules)
│           ├── cards.jl
│           └── rules.jl
│
└── test/                  # Unit & integration tests
```

## 4. Module Responsibilities

- **Core**: minimal `State{P}`, `Action` abstraction, `run_turn!` skeleton
- **Pipeline**: orchestrate atomic effects (registered via macros) in a flow:
  - `Step(op; args, condition, loop)`
  - `Flow(steps)`
  - `run_pipeline!(flow, state, game)` returns flattened results
- **Choice**: separate context & resolution:
  - `ChooseCtx` holds candidates, limits, history
  - `register_strategy(name, fn)` macro for strategy functions
  - `choose!(ctx)` dispatches to selected strategy, returns `ChooseRes`
- **Plugins**: define game data using core abstractions:
  - card definitions via `@define_card` / `@register`
  - `effects = [:some_effect, :pipeline]`
  - plugin‑specific state in `State.data`

## 5. Implementation Roadmap

1. **Core/State & Turn**
   - Finalise `State` keyword constructor
   - Implement basic `Action` type & `run_turn!` loop
2. **Pipeline**
   - Complete `Step`/`Flow` APIs
   - Implement `run_pipeline!` with condition/loop/dynamic args
   - Write tests for simple two‑step flows
3. **Choice**
   - Define `ChooseCtx`/`ChooseRes`
   - Strategy registry and resolver
   - Test random vs fixed strategies
4. **Integration**
   - Wire `run_turn!` to call `run_pipeline!` for `effects` on Actions or cards
   - Smoke test: simple card with point gain
5. **Plugin: Dominion**
   - Port basic Base set cards
   - Implement draw/discard/gain effects
   - Integration tests for `Cellar`, `Smithy`, etc.
6. **Utils & Docs**
   - Asset loading API (`load_png`, `get_png`)
   - Quick Start guide in `docs/`
   - CI for tests and docs deployment

## 6. Phases & Future Extensions

- **P1**: Core engine + pipeline + choice basics
- **P2**: DSL/AST layer for card/effect definitions
- **P3**: Batch self‑play, logging, analytics
- **P4**: AI integration, RL baselines (Flux.jl)
- **P5**: Multi‑game support (Pokémon, Sakura Arms, MtG)
- **P6**: Service abstraction (Elixir/Gleam microservices)
- **P7**: Public DSL editor, strategy diff UI

---

*Use this document to bootstrap new conversations about Itera—just paste and go!*

