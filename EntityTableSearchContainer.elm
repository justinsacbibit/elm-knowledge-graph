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
    ( Model (fst SearchBox.init) Nothing -- TODO: Figure out a nicer way to use SearchBox's init
    , Effects.none
    )


-- UPDATE


type Action
    = NoOp
    | Search SearchBox.Action
    | NewEntities (Maybe EntityTable.Model)


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            ( model
            , Effects.none
            )
        Search searchAction ->
            let
                fx = case searchAction of
                    SearchBox.Query query ->
                        Effects.none
                    SearchBox.Search ->
                        searchKnowledgeGraph model.search.query

                (newSearchBox, searchBoxFx) = SearchBox.update searchAction model.search
            in
               ( { model | search = newSearchBox }
               , batch [ fx, map Search searchBoxFx ]
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
    in
        div []
            [ SearchBox.view (Signal.forwardTo address Search) model.search
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

