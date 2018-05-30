port module Main exposing (..)

import Html exposing (Html, button, div, text, input, h1)
import Html.Attributes exposing (placeholder, class, type_)
import Material
import Material.Button as Button
import Material.Options as Options exposing (css)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias User =
    { name : String
    , photoURL : String
    }


type alias Model =
    { user : User
    , state : String
    , mdl : Material.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model (User "" "") "" Material.model, Cmd.none )



-- Update


type Msg
    = Login
    | LoginUser User
    | Mdl (Material.Msg Msg)


port login : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( { model | state = "logging" }, login "" )

        LoginUser user ->
            ( { model | user = user, state = "login" }, Cmd.none )

        Mdl msg_ ->
            Material.update Mdl msg_ model



-- Subscriptions


port loginUser : (User -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    loginUser LoginUser



-- View


type alias Mdl =
    Material.Model


view : Model -> Html Msg
view model =
    simpleRoute model


simpleRoute : Model -> Html Msg
simpleRoute model =
    if model.state == "login" then
        div
            []
            [ text ("Hello " ++ model.user.name) ]
    else
        div
            [ class "login-container" ]
            [ div [ class "animated fadeInDown" ]
                [ h1 [] [ text "Stand-up Notes" ]
                , Button.render Mdl [ 2 ] model.mdl [ Options.onClick Login, Button.ripple, Button.colored, Button.raised ] [ text "Login with Github" ]
                ]
            ]
