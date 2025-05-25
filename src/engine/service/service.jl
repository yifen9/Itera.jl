module Service
    export Player, Stage, Assembler, Listener, Chooser, Workflow

    include(joinpath("player",    "player.jl"))
    include(joinpath("stage",     "stage.jl"))
    include(joinpath("assembler", "assembler.jl"))
    include(joinpath("listener",  "listener.jl"))
    include(joinpath("chooser",   "chooser.jl"))
    include(joinpath("workflow",  "workflow.jl"))
end