module KnowledgeGraph (main) where

import Effects exposing (Never)
import StartApp exposing (start)
import EntityTableSearchContainer exposing (init, view, update)
import Task


app =
    start { init = init, view = view, update = update, inputs = [] }
    --start { init = init "apple", view = view, update = update, inputs = [] }


main = app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks

