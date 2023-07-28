(globals
    version = 3
    io_order = clockwise
)
( row_margin
  ( top
    ( io_row ring_number = 1 margin = 0)
  )
  ( bottom
    ( io_row ring_number = 1 margin = 0)
  )
  ( left
    ( io_row ring_number = 1 margin = 0)
  )
  ( right
    ( io_row ring_number = 1 margin = 0)
  )
)

(iopad
    (topleft
        (locals ring_number = 1)
        (inst name="tlcorner" cell=PCORNER)
    )
    (topright
        (locals ring_number = 1)
        (inst name="trcorner" cell=PCORNER)
    )
    (bottomright
        (locals ring_number = 1)
        (inst name="brcorner" cell=PCORNER)
    )
    (bottomleft
        (locals ring_number = 1)
        (inst name="blcorner" cell=PCORNER)
    )
)
