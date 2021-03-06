module SearchBox where


import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


-- MODEL

type alias Model =
    { query : String }


init : (Model, Effects Action)
init =
    ( Model ""
    , Effects.none
    )


-- UPDATE

type Action
    = Query String
    | Search


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Query query ->
            ( { model | query = query }
            , Effects.none
            )

        Search ->
            ( model
            , Effects.none
            )


-- VIEW

type alias Context =
    { actions : Signal.Address Action
    , search : Signal.Address String
    }


view : Context -> Model -> Html
view context model =
    div [ class "mui-textfield" ]
        [ input
            [ type' "text"
            , placeholder "Enter a query"
            , value model.query
            , onEnter context.search model.query
            , on "input" targetValue (Signal.message context.actions << Query)
            ]
            []
        ]


onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
    on "keydown"
        (Json.customDecoder keyCode is13)
        (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
    if code == 13 then Ok () else Err "not the right key code"

