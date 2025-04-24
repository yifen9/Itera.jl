"""
Participant module re-exports the generic TreeCycle functionality
to model recursive player/team structures.

Exports:
- `Node{P}`: generic tree node
- `Leaf{P}`: leaf node wrapping a player of type `P`
- `Group{P}`: group node containing sub-nodes
- `current_get!`: get the active leaf value (player)
- `advance!`: advance the active index in-place
- `reset!`: reset all indices to 1
"""
module Participant

using ..TreeCycle

export Node, Leaf, Group, current_get!, advance!, reset!

end # module Participant