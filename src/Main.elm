module Main exposing (main)

import Browser
import Html exposing (Html, article, button, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Msg exposing (Msg(..))


type alias Job =
    { id : Int
    , by : String
    , score : Int
    , time : Int
    , title : String
    , postType : String
    , url : String
    }


type alias Model =
    { jobs : List Job
    }


initialModel : Model
initialModel =
    Model
        [ Job 1 "Me" 1 1 "Hello, jobs!" "job" "https://mattiza.dev"
        , Job 2 "Me" 1 1 "Hello, jobs!" "job" "https://mattiza.dev"
        , Job 3 "Me" 1 1 "Hello, jobs!" "job" "https://mattiza.dev"
        , Job 4 "Me" 1 1 "Hello, jobs!" "job" "https://mattiza.dev"
        , Job 5 "Me" 1 1 "Hello, jobs!" "job" "https://mattiza.dev"
        , Job 6 "Me" 1 1 "Hello, jobs!" "job" "https://mattiza.dev"
        ]


main : Program () Model Msg
main =
    Browser.sandbox { init = initialModel, update = update, view = view }


update : Msg -> Model -> Model
update msg model =
    case msg of
        _ ->
            model


view : Model -> Html Msg
view model =
    div [ class "app-container" ]
        [ h1 [ class "job-header-text" ] [ text "HN Jobs" ]
        , div [ class "divide" ] []
        , div [ class "jobs-container" ] (List.map viewJobCard model.jobs)
        , div [ class "btn-container" ] [ button [ class "load-more-jobs-btn" ] [ text "Load More..." ] ]
        ]


viewJobCard : Job -> Html Msg
viewJobCard job =
    div [ class "job-article" ] [ text <| "Id: " ++ String.fromInt job.id ]
