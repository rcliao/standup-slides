port module Main exposing (..)

import Date exposing (..)
import Date.Extra as Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown
import Keyboard
import Task
import Slides


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
    { id : String
    , name : String
    , photoURL : String
    }


type alias Model =
    { user : Maybe User
    , currentDate : Maybe Date
    , personalNote : Maybe String
    , allNotes : Maybe String
    , route : Route
    , slides : List (List Slides.Slide)
    , slideAxis : Slides.Axis
    , state : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        Nothing
        Nothing
        Nothing
        Nothing
        Summary
        []
        (Slides.Axis 0 0)
        ""
    , (Task.perform GotDate Date.now)
    )



-- Update


type Msg
    = Login
    | LoginUser User
    | RouteMain Route
    | GetAllNotes String
    | GetPersonalNote String
    | GotDate Date
    | KeyMsg Keyboard.KeyCode


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
                [ jsGetAllNotes (NoteID (user.id ++ user.name) (getCurrentWeekNumber model.currentDate))
                , jsGetPersonalNotes (NoteID (user.id ++ user.name) (getCurrentWeekNumber model.currentDate))
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
            ( { model | allNotes = Just notes, slides = (Slides.parse (getAllNotes (Just notes))) }, Cmd.none )

        GetPersonalNote note ->
            ( { model | personalNote = Just note }
            , (jsSetPersonalNote (UserNote (getUserName model.user) (getCurrentWeekNumber model.currentDate) note))
            )

        KeyMsg code ->
            case code of
                -- left
                37 ->
                    ( { model
                        | slideAxis = (Slides.slideLeft model.slideAxis model.slides)
                      }
                    , Cmd.none
                    )

                -- up
                38 ->
                    ( { model
                        | slideAxis = (Slides.slideUp model.slideAxis model.slides)
                      }
                    , Cmd.none
                    )

                -- right
                39 ->
                    ( { model
                        | slideAxis = (Slides.slideRight model.slideAxis model.slides)
                      }
                    , Cmd.none
                    )

                -- down
                40 ->
                    ( { model
                        | slideAxis = (Slides.slideDown model.slideAxis model.slides)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ jsLoginUser LoginUser
        , jsPersonalNote GetPersonalNote
        , jsAllNotes GetAllNotes
        , Keyboard.downs KeyMsg
        ]



-- View


view : Model -> Html Msg
view model =
    simpleRoute model


simpleRoute : Model -> Html Msg
simpleRoute model =
    case model.user of
        Just _ ->
            mainView model

        Nothing ->
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
        [ (Slides.view
            (Slides.Model model.slideAxis model.slides)
          )
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


getNextWeekNumber : Maybe Date -> String
getNextWeekNumber date =
    Maybe.map Date.weekNumber date
        |> Maybe.withDefault 0
        |> ((+) 1)
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
