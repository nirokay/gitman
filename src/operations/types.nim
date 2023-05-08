import options

type Operation* = object
    name*, desc*: string
    alias*: Option[seq[string]]
    call*: proc()

var operations*: seq[Operation]
