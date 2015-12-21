module EntityRow where

import Effects
import Html exposing (..)
import Html.Attributes exposing (..)
import Regex
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
            [ unescape model.name ]
        , td []
            [ unescape (String.join ", " model.types) ]
        , td []
            [ maybeCell model.description (\desc -> unescape desc) ]
        , td []
            [ maybeCell model.imageContentUrl (\url -> img [ src url ] []) ]
        , td []
            [ maybeCell model.detailedDescription (\detail -> unescape detail.articleBody) ]
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


unescape : String -> Html
unescape value =
    let regex = Regex.regex (Regex.escape "&amp;")
    in
       text (Regex.replace Regex.All regex (\_ -> "&") value)


maybeCell : Maybe a -> (a -> Html) -> Html
maybeCell maybe renderer =
    case maybe of
        Just val ->
            renderer val
        Nothing ->
            span [] []

