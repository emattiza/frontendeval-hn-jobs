module Main exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (Html, a, article, button, div, h1, h2, p, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (..)
import Job exposing (Job, viewJob)
import JobFeed exposing (JobFeed)
import Msg exposing (Msg(..), getCurrentJobFeed, getFirstJobs, getMoreJobs)
import RemoteData exposing (RemoteData(..), WebData)
import String exposing (padLeft)
import Task
import Time exposing (millisToPosix)


type alias Model =
    { jobs : Array Job
    , jobFeed : WebData JobFeed
    , firstJobs : WebData (List Job)
    , nextJobs : WebData (List Job)
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { jobs = Array.empty
      , jobFeed = Loading
      , firstJobs = NotAsked
      , nextJobs = NotAsked
      }
    , Task.attempt
        (\result -> LoadFeed (RemoteData.fromResult result))
        getCurrentJobFeed
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
            let
                start =
                    Array.length model.jobs - 1

                end =
                    start + 6
            in
            ( model, Task.perform GotMoreJobs (getMoreJobs model.jobFeed start end) )

        LoadFeed feed ->
            case feed of
                Success newFeed ->
                    ( { model
                        | jobFeed = feed
                        , firstJobs = Loading
                      }
                    , Task.attempt
                        (\result -> GotFirstJobs <| RemoteData.fromResult result)
                        (getFirstJobs newFeed)
                    )

                _ ->
                    ( { model | jobFeed = feed }, Cmd.none )

        GotFirstJobs newJobs ->
            case newJobs of
                Success gotJobs ->
                    ( { model
                        | firstJobs = newJobs
                        , jobs = Array.fromList gotJobs
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model | firstJobs = newJobs }, Cmd.none )

        GotMoreJobs moreJobs ->
            case moreJobs of
                Success gotJobs ->
                    ( { model
                        | nextJobs = moreJobs
                        , jobs = Array.append model.jobs (Array.fromList gotJobs)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model | nextJobs = moreJobs }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "app-container" ]
        [ h1 [ class "job-header-text" ] [ text "HN Jobs" ]
        , div [ class "divide" ] []
        , viewJobs model.jobs
        , div
            [ class "btn-container" ]
            [ button
                [ onClick LoadMoreJobs, class "load-more-jobs-btn" ]
                [ text "Load More..." ]
            ]
        ]


viewJobs : Array Job -> Html Msg
viewJobs jobs =
    div
        [ class "jobs-container" ]
        (Array.toList <| Array.map viewJob jobs)