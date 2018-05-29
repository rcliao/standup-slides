port module Main exposing (..)

import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (placeholder, class, type_)
import Html.Events exposing (onClick)

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- Model
type alias Model =
    { name : String
    }

init : (Model, Cmd Msg)
init =
    (Model "Eric", Cmd.none)



-- Update


type Msg
    = Name String
    | Login
    | LoginUsers (String)


port login : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Name name ->
            ({ model | name = name }, Cmd.none)
        Login ->
            ({ model | name = "login" }, login "")
        LoginUsers user ->
            ({ model | name = user }, Cmd.none )


-- Subscriptions

port loginUser : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
    loginUser LoginUsers


-- View


view : Model -> Html Msg
view model =
    div
        []
        [
            button [ class "login-button", onClick Login ] [ text model.name ]
        ]
