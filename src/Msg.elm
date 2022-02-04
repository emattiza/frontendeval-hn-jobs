module Msg exposing (..)

import RemoteData
import RemoteData exposing (WebData)
import Job exposing (Job, decodeJobDetails)
import JobFeed exposing (JobFeed, decodeJobFeed)
import Http
import Url.Builder exposing (crossOrigin)

type Msg
    = LoadMoreJobs
    | GotJobsFeed (WebData JobFeed)
    | GotJob (WebData Job)


itemUrl : Int -> String
itemUrl itemId =
    crossOrigin base [ "v0", "item", String.fromInt itemId ] []

base : String
base =
    "https://hacker-news.firebaseio.com"

latestJobsUrl : String
latestJobsUrl =
    crossOrigin base [ "v0", "jobstories.json" ] []

getJobDetails : Int -> Cmd Msg
getJobDetails itemId =
    Http.get
        { url = itemUrl itemId
        , expect = Http.expectJson (RemoteData.fromResult >> GotJob) decodeJobDetails
        }

getCurrentJobFeed : Cmd Msg
getCurrentJobFeed =
    Http.get
        { url = latestJobsUrl
        , expect = Http.expectJson (RemoteData.fromResult >> GotJobsFeed) decodeJobFeed
        }
