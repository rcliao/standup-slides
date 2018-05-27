module Main exposing (..)

import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (placeholder, type_)
import Html.Events exposing (onInput)


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }



-- Model


type alias Model =
    { name : String
    }


model : Model
model =
    Model "Eric"



-- Update


type Msg
    = Name String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }



-- View


view : Model -> Html Msg
view model =
    Html.node "wired-card"
        []
        [ Html.node "wired-input" [ type_ "text", placeholder "Name", onInput Name ] []
        , div [] [ text model.name ]
        ]
