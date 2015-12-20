module EntityTable where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)

import EntityRow


-- MODEL

type alias Model =
    List EntityRow.Model


init : Model -> (Model, Effects Action)
init model =
    ( model
    , Effects.none
    )


-- UPDATE


type Action
    = NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            (model, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
    let rows = List.map (viewRow address) model
    in
       table [ class "mui-table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "Types" ]
                    , th [] [ text "Description" ]
                    , th [] [ text "Image" ]
                    , th [] [ text "Detailed Description" ]
                    , th [] [ text "URL" ]
                    , th [] [ text "Result Score" ]
                    ]
                ]
            , tbody []
                ( rows )
            ]

viewRow : Signal.Address Action -> EntityRow.Model -> Html
viewRow address entityModel =
    EntityRow.view (Signal.forwardTo address (always NoOp)) entityModel

