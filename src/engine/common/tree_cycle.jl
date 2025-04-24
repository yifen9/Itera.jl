module TreeCycle

export Node, Leaf, Group, current_get!, advance!, reset!

abstract type Node end

"""
Leaf{T}(value::T)

Wraps a value as a strong-typed leaf node.
"""
mutable struct Leaf{T} <: Node
    value::T
end

"""
Group(member_list::Vector{<:Node})

Creates a weakly typed group node with an index tracker.
The `member_list` may contain `Leaf{T}` or nested `Group`.
"""
mutable struct Group <: Node
    member_list::Vector{Node}
    index_current::Int
end

Group(member_list::Vector{<:Node}) = Group(member_list, 1)

"""
current_get!(leaf::Leaf{T}) -> T

Returns the value inside the leaf.
"""
current_get!(leaf::Leaf{T}) where T = leaf.value

"""
current_get!(group::Group) -> T

Recursively gets the current leaf value from a group tree.
"""
function current_get!(group::Group)
    current = group.member_list[group.index_current]
    return current_get!(current)
end

"""
advance!(group::Group) -> Group

Recursively advances to the next child node.
"""
function advance!(group::Group)
    node = group.member_list[group.index_current]
    if node isa Group
        old_index = node.index_current
        advance!(node)
        if node.index_current == 1 && old_index != 1
            group.index_current = group.index_current % length(group.member_list) + 1
        end
    else
        group.index_current = group.index_current % length(group.member_list) + 1
    end
    return group
end

advance!(leaf::Leaf) = error("Cannot advance a leaf directly; advance its parent group.")

"""
reset!(node::Node) -> Node

Reset a tree to its first element.
"""
reset!(leaf::Leaf) = leaf
function reset!(group::Group)
    group.index_current = 1
    for child in group.member_list
        reset!(child)
    end
    return group
end

end # module TreeCycle