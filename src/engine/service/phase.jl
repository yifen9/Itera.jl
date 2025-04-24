"""
Phase module re-exports the generic TreeCycle functionality
to model recursive phase/subphase structures.

Exports:
- `Node{F}`: generic tree node for phases
- `Leaf{F}`: leaf node wrapping an action function of type `F`
- `Group{F}`: group node containing sub-phases
- `current_get!`: get the active leaf value (action function)
- `advance!`: advance the active index in-place
- `reset!`: reset all indices to 1
"""
module Phase

using ..TreeCycle

export Node, Leaf, Group, current_get!, advance!, reset!

end # module Phase