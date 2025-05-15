module TreeCycle

export Node, Leaf, Group, build, current_get, advance!, reset!

abstract type Node end

mutable struct Leaf{T} <: Node
    value::T
    parent::Union{WeakRef, Nothing}
end

mutable struct Group <: Node
    child_list::Vector{Node}
    child_index_current::Int
    parent::Union{WeakRef, Nothing}
end

Leaf(value::T; parent::Union{WeakRef, Nothing}=nothing) where T = Leaf{T}(value, parent)

Group(child_list::Vector; parent::Union{WeakRef, Nothing}=nothing) = Group(Vector{Node}(child_list), 1, parent)

function build(data; parent_reference::Bool=true)
    if data isa AbstractVector
        if isempty(data)
            error("Build empty Group")
        else
            group = Group(Vector{Node}())
            for data_item in data
                node_parent = parent_reference ? WeakRef(group) : nothing
                node = build(data_item; node_parent)
                push!(group.child_list, node)
            end
            return group
        end
    else
        return Leaf(data)
    end
end

current_get(node::Node) = node isa Leaf ? node.value : current_get(node.child_list[node.child_index_current])

function advance!(node::Node; condition::Bool=true)
    if node isa Leaf
        error("Advance Leaf of Node")
    else
        child = node.child_list[node.child_index_current]
        if child isa Group
            index_old = child.child_index_current
            advance!(child)
            if child.child_index_current == 1 && index_old != 1
                node.child_index_current = node.child_index_current % length(node.child_list) + 1
            end
        else
            node.child_index_current = node.child_index_current % length(node.child_list) + 1
        end
        return node
    end
end

function reset!(node::Node)
    if node isa Group
        node.child_index_current = 1
        for child in node.child_list
            reset!(child)
        end
    end
    return node
end

end