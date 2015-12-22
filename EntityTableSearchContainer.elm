module EntityTableSearchContainer where

import Effects exposing (Effects, batch, map)
import Html exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import Task

import SearchBox
import EntityTable
import EntityRow


-- MODEL

type alias Model =
    { search : SearchBox.Model
    , table : Maybe EntityTable.Model
    }


init : (Model, Effects Action)
init =
    let (search, fx) = SearchBox.init
    in
        ( Model search Nothing
        , map SearchBox fx
        )


-- UPDATE


type Action
    = NoOp
    | SearchBox SearchBox.Action
    | Search String
    | NewEntities (Maybe EntityTable.Model)


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            ( model
            , Effects.none
            )

        SearchBox searchAction ->
            let
                (searchBox, fx) = SearchBox.update searchAction model.search
            in
               ( { model | search = searchBox }
               , map SearchBox fx
               )

        Search query ->
            let fx = searchKnowledgeGraph query
            in
               ( model
               , fx
               )

        NewEntities maybeEntities ->
            ( { model | table = maybeEntities }
            , Effects.none
            )


-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
    let tableModel = case model.table of
         Just a ->
            a
         Nothing ->
            []

        context =
            SearchBox.Context
                (Signal.forwardTo address SearchBox)
                (Signal.forwardTo address Search)
    in
        div []
            [ SearchBox.view context model.search
            , EntityTable.view (Signal.forwardTo address (always NoOp)) tableModel
            ]


-- EFFECTS

searchKnowledgeGraph : String -> Effects Action
searchKnowledgeGraph query =
    Http.get decodeData (queryUrl query)
        |> Task.toMaybe
        |> Task.map NewEntities
        |> Effects.task


(=>) : a -> b -> ( a, b )
(=>) = (,) -- Black magic operator


queryUrl : String -> String
queryUrl query =
    Http.url "https://kgsearch.googleapis.com/v1/entities:search"
        [ "query" => query
        , "key" => "AIzaSyC-CzQ4NzurDdc9d7ItDLlUi--K0KDC9ZI"
        , "limit" => "10"
        , "indent" => "false"
        ]


decoder : Json.Decoder EntityRow.Model
decoder =
    Json.object6 EntityRow.Model
        (Json.at ["result", "name"] Json.string)
        (Json.at ["result", "@type"] (Json.list Json.string))
        (Json.maybe (Json.at ["result", "description"] Json.string))
        (Json.maybe (Json.at ["result", "image", "contentUrl"] Json.string))
        (Json.maybe
            (Json.at ["result", "detailedDescription"]
                (Json.object2 EntityRow.DetailedDescription
                    ("articleBody" := Json.string)
                    ("url" := Json.string)
                )
            )
        )
        (Json.at ["resultScore"] Json.float)


decodeData : Json.Decoder (List EntityRow.Model)
decodeData =
    Json.at ["itemListElement"] (Json.list decoder)

