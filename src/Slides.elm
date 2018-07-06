module Slides exposing (..)

import Css exposing (..)
import Html
import Html.Attributes
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Markdown
import List
import Maybe
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


slideUp : Axis -> List (List Slide) -> Axis
slideUp axis slides =
    (Axis axis.x (Basics.max 0 (axis.y - 1)))


slideDown : Axis -> List (List Slide) -> Axis
slideDown axis slides =
    (Axis axis.x (Basics.min ((getSubLength axis.x slides) - 1) (axis.y + 1)))


slideLeft : Axis -> List (List Slide) -> Axis
slideLeft axis model =
    (Axis (Basics.max 0 (axis.x - 1)) 0)


slideRight : Axis -> List (List Slide) -> Axis
slideRight axis slides =
    (Axis (Basics.min ((List.length slides) - 1) (axis.x + 1)) 0)



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


view : Model -> Html.Html msg
view model =
    toUnstyled
        (div
            [ class "slides-container"
            , css
                [ Css.height (Css.em 30)
                , displayFlex
                , backgroundColor (hex "#666")
                , alignItems center
                , justifyContent center
                , textAlign center
                , flexDirection column
                , position relative
                ]
            ]
            (List.append
                (toSlideHtmls model.slides model.axis)
                [ div
                    [ class "axis"
                    , css
                        [ position absolute
                        , bottom (Css.em 0.5)
                        , right (Css.em 1)
                        ]
                    ]
                    [ text (toString model.axis.x ++ "," ++ toString model.axis.y) ]
                ]
            )
        )


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
        Just (Html.Styled.fromUnstyled (Markdown.toHtml [ Html.Attributes.class "vertical-section" ] slide.content))
    else
        Nothing


verticalSeperator : String
verticalSeperator =
    "\n\n\n"


horizontalSeperator : String
horizontalSeperator =
    "\n\n\n\n"



-- helpers


getSubLength : Int -> List (List a) -> Int
getSubLength i list =
    List.drop i list
        |> List.head
        |> Maybe.withDefault []
        |> List.length
