port module Main exposing (..)

import Date exposing (..)
import Date.Extra as Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown
import Task


noteTemplate : String -> String
noteTemplate username =
    "# "
        ++ username
        ++ """


## Last week
* Category - short description


## This week
* Category - short description


## Blockers
* Need help on CC from {name of other}
"""



-- output


port jsLogin : () -> Cmd msg


port jsGetAllNotes : NoteID -> Cmd msg


port jsGetPersonalNotes : NoteID -> Cmd msg


port jsSetPersonalNote : UserNote -> Cmd msg


port jsViewChange : String -> Cmd msg


port jsFullScreen : String -> Cmd msg



-- input


port jsLoginUser : (User -> msg) -> Sub msg


port jsPersonalNote : (String -> msg) -> Sub msg


port jsAllNotes : (String -> msg) -> Sub msg



-- Main Program


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


type alias UserNote =
    { username : String
    , id : String
    , content : String
    }


type alias NoteID =
    { username : String
    , id : String
    }


type alias User =
    { name : String
    , photoURL : String
    }


type alias Model =
    { user : Maybe User
    , currentDate : Maybe Date
    , personalNote : Maybe String
    , allNotes : Maybe String
    , route : Route
    , state : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing Nothing Nothing Nothing Summary "", (Task.perform GotDate Date.now) )



-- Update


type Msg
    = Login
    | LoginUser User
    | RouteMain Route
    | GetAllNotes String
    | GetPersonalNote String
    | GotDate Date
    | RequestFullScreen String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( { model | state = "logging" }, jsLogin () )

        GotDate date ->
            ( { model | currentDate = Just date }, Cmd.none )

        LoginUser user ->
            ( { model | user = Just user }
            , Cmd.batch
                [ jsGetAllNotes (NoteID user.name (getCurrentWeekNumber model.currentDate))
                , jsGetPersonalNotes (NoteID user.name (getCurrentWeekNumber model.currentDate))
                ]
            )

        RouteMain route ->
            ( { model | route = route }
            , if route == model.route then
                Cmd.none
              else
                jsViewChange (toString route)
            )

        GetAllNotes notes ->
            ( { model | allNotes = Just notes }, Cmd.none )

        GetPersonalNote note ->
            ( { model | personalNote = Just note }
            , (jsSetPersonalNote (UserNote (getUserName model.user) (getCurrentWeekNumber model.currentDate) note))
            )

        RequestFullScreen selector ->
            ( model, (jsFullScreen selector) )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ jsLoginUser LoginUser
        , jsPersonalNote GetPersonalNote
        , jsAllNotes GetAllNotes
        ]



-- View


view : Model -> Html Msg
view model =
    simpleRoute model


simpleRoute : Model -> Html Msg
simpleRoute model =
    if model.user /= Nothing then
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
        , b [] [ text (getUserName model.user) ]
        , Markdown.toHtml [ class "summary-container" ] (getAllNotes model.allNotes)
        ]


notesView : Model -> Html Msg
notesView model =
    textarea [ id "note_editor" ] [ text (getPersonalNote model.personalNote model.user) ]


standUpView : Model -> Html Msg
standUpView model =
    div [ class "standup-container" ]
        [ div [ class "actions" ]
            [ node "mwc-button"
                [ class "light"
                , attribute "onClick" "window.requestFullScreen()"
                , attribute "raised" "true"
                , attribute "label" "Full Screen"
                ]
                []
            ]
        , div [ class "reveal" ]
            [ div [ class "slides" ]
                [ section
                    [ attribute "data-markdown" ""
                    , attribute "data-separator" "^\\r?\\n\\r?\\n\\r?\\n"
                    , attribute "data-separator-vertical" "^\\r?\\n\\r?\\n"
                    , attribute "data-charset" "iso-8859-15"
                    ]
                    [ textarea
                        [ attribute "data-template" ""
                        ]
                        [ text (getAllNotes model.allNotes) ]
                    ]
                ]
            ]
        ]


mainNavView : Model -> Html Msg
mainNavView model =
    nav
        []
        [ a
            [ class (isNavigationActive model.route Summary)
            , onClick (RouteMain Summary)
            ]
            [ text "Summary" ]
        , a
            [ class (isNavigationActive model.route Notes)
            , onClick (RouteMain Notes)
            ]
            [ text "Notes" ]
        , a
            [ class (isNavigationActive model.route StandUp)
            , onClick (RouteMain StandUp)
            ]
            [ text "Stand-up" ]
        ]


isNavigationActive : Route -> Route -> String
isNavigationActive currentNav nav =
    if currentNav == nav then
        "active"
    else
        ""


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



-- Helpers


plusOne : Int -> Int
plusOne n =
    n + 1


getNextWeekNumber : Maybe Date -> String
getNextWeekNumber date =
    Maybe.map Date.weekNumber date
        |> Maybe.withDefault 0
        |> plusOne
        |> toString


getYear : Maybe Date -> String
getYear date =
    Maybe.map Date.weekYear date
        |> Maybe.withDefault 0
        |> toString


getCurrentWeekNumber : Maybe Date -> String
getCurrentWeekNumber date =
    Maybe.map Date.weekNumber date
        |> Maybe.withDefault 0
        |> toString
        |> String.append "-"
        |> String.append (getYear date)


getUserName : Maybe User -> String
getUserName user =
    case user of
        Nothing ->
            "Unknown"

        Just currentUser ->
            currentUser.name


getPersonalNote : Maybe String -> Maybe User -> String
getPersonalNote note user =
    case note of
        Nothing ->
            noteTemplate (getUserName user)

        Just personalNote ->
            personalNote


getAllNotes : Maybe String -> String
getAllNotes note =
    case note of
        Nothing ->
            "No notes found"

        Just allNotes ->
            allNotes
