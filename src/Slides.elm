module Slides exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import String exposing (split)


verticalSeperator : String
verticalSeperator =
    "\n\n"


horizontalSeperator : String
horizontalSeperator =
    "\n\n\n"


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


type Msg
    = ChangeSlide



-- TODO: Need to parse input string to a list of slides


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


view : Model -> Html Msg
view model =
    div
        [ class "slides-container" ]
        (toSlideHtmls model.slides)


toSlideHtmls : List (List Slide) -> List (Html Msg)
toSlideHtmls slides =
    List.map toSlideSectionHtml slides


toSlideSectionHtml : List Slide -> Html Msg
toSlideSectionHtml slides =
    section [] (List.map toSlideHtml slides)


toSlideHtml : Slide -> Html msg
toSlideHtml slide =
    Markdown.toHtml [] slide.content