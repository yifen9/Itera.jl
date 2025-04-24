module Tracker

export track!, get, clear!, save

using JSON

using ..Snapshot

const _TRACK = Ref([])

"""
track!(state::Game)

Append a deep snapshot of current state.
"""
function track!(state)
    push!(_TRACK[], Snapshot.snapshot(state))
end

"""
get() -> Vector{Game}

Return full trace of tracked states.
"""
get() = copy(_TRACK[])

"""
clear!()

Clear all tracked snapshots.
"""
clear!() = empty!(_TRACK[])

"""
save(path::String)

Save all tracked snapshots as JSON (via summarize).
"""
function save(path::String)
    summary_list = [Snapshot.summarize(s) for s in _TRACK[]]
    open(path, "w") do io
        JSON.print(io, summary_list)
    end
end

end # module Tracker