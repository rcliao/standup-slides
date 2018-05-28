module Main exposing (..)

import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (placeholder, class, type_)
import Html.Events exposing (onClick)

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
    | Login


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }
        Login ->
            { model | name = "login" }



-- View


view : Model -> Html Msg
view model =
    div
        []
        [
        button [ class "login-button", onClick Login ] [ text model.name ]
        ]
