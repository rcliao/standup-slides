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
    { index : Axis
    , slides : List (List Slide)
    }



-- init


init : Model
init =
    Model (Axis 0 0) []



-- update
-- type Msg
--     = ChangeSlide
-- view


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
        (toSlideHtmls model.slides)


toSlideHtmls : List (List Slide) -> List (Html msg)
toSlideHtmls slides =
    List.map toSlideSectionHtml slides


toSlideSectionHtml : List Slide -> Html msg
toSlideSectionHtml slides =
    section [ class "horizontal-section" ] (List.map toSlideHtml slides)


toSlideHtml : Slide -> Html msg
toSlideHtml slide =
    Markdown.toHtml [ class "vertical-section" ] slide.content


verticalSeperator : String
verticalSeperator =
    "\n\n\n"


horizontalSeperator : String
horizontalSeperator =
    "\n\n\n\n"
