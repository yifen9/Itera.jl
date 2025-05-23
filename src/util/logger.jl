module Logger

export log!, get, clear!, string, save

using Dates
using JSON

mutable struct Entry
    time::DateTime
    kind::Symbol
    tag::Union{Nothing,Symbol}
    message::String
end

const _LOG = Ref(Entry[])

"""
log!(kind::Symbol; tag=nothing, message="")

Append a log entry of a step/phase/effect/etc.
"""
function log!(kind::Symbol; tag=nothing, message="")
    push!(_LOG[], Entry(now(), kind, tag, message))
end

"""
get() -> Vector{Entry}

Return all log entries.
"""
get() = copy(_LOG[])

"""
clear!()

Clear the internal log buffer.
"""
clear!() = empty!(_LOG[])

"""
string() -> String

Return all logs as a printable string.
"""
string() = join(["[$e.time][$e.kind][$e.tag] $(e.message)" for e in _LOG[]], "\n")

"""
save(path::String)

Save logs to file as JSON.
"""
function save(path::String)
    json = [Dict("time"=>Base.string(e.time), "kind"=>e.kind, "tag"=>e.tag, "message"=>e.message) for e in _LOG[]]
    open(path, "w") do io
        JSON.print(io, json)
    end
end

end # module Logger