module JobFeed exposing (..)

import Json.Decode exposing (Decoder, list, int)

type alias JobFeed =
    List JobId

type alias JobId =
    Int

decodeJobFeed : Decoder JobFeed
decodeJobFeed = list int

