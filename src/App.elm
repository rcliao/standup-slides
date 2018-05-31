port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type Route
    = Summary
    | Notes
    | StandUp


type alias User =
    { name : String
    , photoURL : String
    }


type alias Model =
    { user : User
    , route : Route
    , state : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model (User "" "") Summary "", Cmd.none )



-- Update


type Msg
    = Login
    | LoginUser User
    | RouteMain Route


port login : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( { model | state = "logging" }, login "" )

        LoginUser user ->
            ( { model | user = user }, Cmd.none )

        RouteMain route ->
            ( { model | route = route }, Cmd.none )



-- Subscriptions


port loginUser : (User -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    loginUser LoginUser



-- View


view : Model -> Html Msg
view model =
    simpleRoute model


simpleRoute : Model -> Html Msg
simpleRoute model =
    if model.user.name /= "" then
        mainView model
    else
        loginView model


mainView : Model -> Html Msg
mainView model =
    div
        [ class "main-container" ]
        [ mainNavView model
        , mainRouteView model
        ]


mainRouteView : Model -> Html Msg
mainRouteView model =
    case model.route of
        Summary ->
            summaryView model

        Notes ->
            notesView model

        StandUp ->
            standUpView model


summaryView : Model -> Html Msg
summaryView model =
    div []
        [ text "Hello "
        , b [] [ text model.user.name ]
        , pre [] [ text """# Weekly Note


## Eric Liao


### Last Week

* Hello
* Hello 2


### This week

* Feature 1
* Fix 2


### Blocker

* QA
""" ]
        ]


notesView : Model -> Html Msg
notesView model =
    div [] [ text "Insert Editor here" ]


standUpView : Model -> Html Msg
standUpView model =
    div [] [ text "Insert reveal.js presentation here" ]


mainNavView : Model -> Html Msg
mainNavView model =
    nav
        []
        [ a [ onClick (RouteMain Summary) ] [ text "Summary" ]
        , a [ onClick (RouteMain Notes) ] [ text "Notes" ]
        , a [ onClick (RouteMain StandUp) ] [ text "Stand-up" ]
        ]


loginView : Model -> Html Msg
loginView model =
    div
        [ class "login-container" ]
        [ div [ class "animated fadeInDown" ]
            [ h1 [] [ text "Stand-up Notes" ]
            , node "mwc-button"
                [ class "light"
                , onClick Login
                , attribute "raised" "true"
                , attribute "label" "Login with Github"
                ]
                []
            ]
        ]
