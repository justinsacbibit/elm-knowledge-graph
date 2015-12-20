module EntityRow where

import Effects
import Html exposing (..)
import Html.Attributes exposing (..)
import String


-- MODEL

type alias DetailedDescription =
    { articleBody : String
    , url : String
    }


type alias Model =
    { name : String
    , types : List String
    , description : Maybe String
    , imageContentUrl : Maybe String
    , detailedDescription : Maybe DetailedDescription
    , resultScore : Float
    }


-- UPDATE

type Action =
    NoOp


update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
    (model, Effects.none)


-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
    tr []
        [ td []
            [ text model.name ]
        , td []
            [ text (String.join ", " model.types) ]
        , td []
            [ maybeCell model.description (\desc -> text desc) ]
        , td []
            [ maybeCell model.imageContentUrl (\url -> img [ src url ] []) ]
        , td []
            [ maybeCell model.detailedDescription (\detail -> text detail.articleBody) ]
        , td []
            [ maybeCell model.detailedDescription
                (\detail ->
                    a
                        [ href detail.url, target "_blank" ]
                        [ text "Wikipedia Article" ]
                )
            ]
        , td []
            [ text (toString model.resultScore) ]
        ]


maybeCell : Maybe a -> (a -> Html) -> Html
maybeCell maybe renderer =
    case maybe of
        Just val ->
            renderer val
        Nothing ->
            span [] []

