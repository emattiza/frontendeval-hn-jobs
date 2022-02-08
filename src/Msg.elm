module Msg exposing (..)

import Array
import Http exposing (Error, Response(..), stringResolver)
import Job exposing (Job, decodeJobDetails)
import JobFeed exposing (JobFeed, JobId, decodeJobFeed)
import Json.Decode exposing (Decoder, decodeString, errorToString)
import Platform exposing (Task)
import RemoteData exposing (RemoteData(..), WebData)
import Task exposing (Task)
import Url exposing (Protocol(..))
import Url.Builder exposing (crossOrigin)


type Msg
    = LoadMoreJobs
    | LoadFeed (WebData JobFeed)
    | GotFirstJobs (WebData (List Job))
    | GotMoreJobs (WebData (List Job))


base : String
base =
    "https://hacker-news.firebaseio.com"


itemUrl : Int -> String
itemUrl itemId =
    crossOrigin base [ "v0", "item", String.fromInt itemId ++ ".json" ] []


latestJobsUrl : String
latestJobsUrl =
    crossOrigin base [ "v0", "jobstories.json" ] []


getJobDetails : JobId -> Task Http.Error Job
getJobDetails itemId =
    Http.task
        { url = itemUrl itemId
        , body = Http.emptyBody
        , headers = []
        , method = "GET"
        , timeout = Nothing
        , resolver = stringResolver <| jsonResponseToResult decodeJobDetails
        }


getJobsDetails : JobFeed -> Task Http.Error (List Job)
getJobsDetails itemIds =
    case itemIds of
        [] ->
            Task.succeed []

        ids ->
            Task.sequence (List.map (\id -> getJobDetails id) ids)


getCurrentJobFeed : Task Http.Error JobFeed
getCurrentJobFeed =
    Http.task
        { url = latestJobsUrl
        , body = Http.emptyBody
        , headers = []
        , method = "GET"
        , timeout = Nothing
        , resolver = stringResolver <| jsonResponseToResult decodeJobFeed
        }


getFirstJobs : JobFeed -> Task Error (List Job)
getFirstJobs jobs =
        let 
            jobsArray = Array.fromList jobs
            firstJobs = Array.toList <| Array.slice 0 9 jobsArray
        in
            Task.sequence <| List.map getJobDetails firstJobs

getMoreJobs : WebData JobFeed -> Int -> Int -> Task x (WebData (List Job))
getMoreJobs jobs start end =
    case jobs of
        Success feed ->
            let
                jobsArray = Array.fromList feed
                nextJobs = Array.toList <| Array.slice start end jobsArray
            in
                RemoteData.fromTask (Task.sequence (List.map getJobDetails nextJobs))

        _ -> Task.succeed (RemoteData.succeed [])


{-
   Task.andThen
       getJobsDetails
       (getCurrentJobFeed
           |> Task.map (sliceList start end)
       )
       |> RemoteData.fromTask
-}
{- So we have to rewrite elm's expectJson to generate Task instead of Cmd msg...
   Yeah...
   this can be an elm install, or just leave for explicitness
-}


jsonResponseToResult : Decoder a -> Response String -> Result Http.Error a
jsonResponseToResult decoder response =
    case response of
        BadUrl_ url ->
            Result.Err (Http.BadUrl url)

        Timeout_ ->
            Result.Err Http.Timeout

        NetworkError_ ->
            Result.Err Http.NetworkError

        BadStatus_ meta _ ->
            Result.Err (Http.BadStatus meta.statusCode)

        GoodStatus_ _ body ->
            decodeString decoder body
                |> Result.mapError decodeErrorsAreBadBody



{- *waves hands around* magic casting of bad decode into http error (which it isn't, but hey, good enough for today) -}


decodeErrorsAreBadBody : Json.Decode.Error -> Http.Error
decodeErrorsAreBadBody decodeError =
    Http.BadBody (errorToString decodeError)



{- Chaining tasks that depend on each other to complete -}


sliceList : Int -> Int -> List a -> List a
sliceList start end list =
    list
        |> Array.fromList
        |> Array.slice start end
        |> Array.toList
