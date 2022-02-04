module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Job exposing (Job)
import JobFeed exposing (JobFeed)
import Msg exposing (Msg(..), getCurrentJobFeed)
import RemoteData exposing (RemoteData(..), WebData)



type alias Model =
    { jobs : List Job
    , currentJob : WebData Job
    , jobFeed : WebData JobFeed
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { jobs = []
      , jobFeed = Loading
      , currentJob = NotAsked
      }
    , getCurrentJobFeed
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }






update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadMoreJobs ->
            ( model, Cmd.none )

        GotJobsFeed feed ->
            ( { model | jobFeed = feed }, Cmd.none )

        GotJob job ->
            ( { model | currentJob = job }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "app-container" ]
        [ h1 [ class "job-header-text" ] [ text "HN Jobs" ]
        , div [ class "divide" ] []
        , viewJobs model
        , div [ class "btn-container" ] [ button [ onClick LoadMoreJobs, class "load-more-jobs-btn" ] [ text "Load More..." ] ]
        ]


viewJobs : Model -> Html Msg
viewJobs _ =
    div [ class "jobs-container" ] []
