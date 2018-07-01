module Slides exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import String exposing (split)


-- model


type alias Slide =
    { content : String
    }


type alias Axis =
    { x : Int
    , y : Int
    }


type alias Model =
    { axis : Axis
    , slides : List (List Slide)
    }



-- init


init : Model
init =
    Model (Axis 0 0) []



-- update


type Msg
    = ChangeSlide Axis


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeSlide axis ->
            ( { model | axis = axis }, Cmd.none )



--  view


parse : String -> List (List Slide)
parse input =
    (split horizontalSeperator input)
        -- list of horizontal contents
        |> List.map (split verticalSeperator)
        -- for each horizontal content build a list of vertical contents
        |> List.map (List.map (toSlide))


toSlide : String -> Slide
toSlide content =
    { content = content }



-- TODO: build a way to do slides transition (vertical and horizontal)
-- TODO: have style to scale elements to center


view : Model -> Html msg
view model =
    div
        [ class "slides-container" ]
        (toSlideHtmls model.slides model.axis)


toSlideHtmls : List (List Slide) -> Axis -> List (Html msg)
toSlideHtmls slides axis =
    List.indexedMap (toSlideSectionHtml axis) slides
        |> List.filterMap identity


toSlideSectionHtml : Axis -> Int -> List Slide -> Maybe (Html msg)
toSlideSectionHtml axis i slides =
    if axis.x == i then
        Just
            (section
                [ class "horizontal-section"
                ]
                (List.indexedMap (toSlideHtml axis) slides
                    |> List.filterMap identity
                )
            )
    else
        Nothing


toSlideHtml : Axis -> Int -> Slide -> Maybe (Html msg)
toSlideHtml axis i slide =
    if axis.y == i then
        Just (Markdown.toHtml [ class "vertical-section" ] slide.content)
    else
        Nothing


verticalSeperator : String
verticalSeperator =
    "\n\n\n"


horizontalSeperator : String
horizontalSeperator =
    "\n\n\n\n"
