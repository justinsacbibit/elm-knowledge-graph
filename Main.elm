module KnowledgeGraph (main) where

import Effects exposing (Never)
import Html
import StartApp exposing (start)
import Task

import EntityTableSearchContainer exposing (init, view, update)


app : StartApp.App EntityTableSearchContainer.Model
app =
    start { init = init, view = view, update = update, inputs = [] }


main : Signal Html.Html
main = app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks

