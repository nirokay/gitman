
type Operation* = object
    name*: string
    aliases*: seq[string]

    description*: string
    usage*: string
    procedure*: proc()

proc call*(op: Operation) =
    op.procedure()
