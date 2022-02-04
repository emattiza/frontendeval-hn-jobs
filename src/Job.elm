module Job exposing (..)

import Html exposing (Html, div, h2, p, text)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, field, int, string)
import Json.Decode exposing (maybe)


type alias Job =
    { id : Int
    , by : String
    , score : Int
    , time : Int
    , title : String
    , postType : String
    , url : Maybe String
    }


decodeJobDetails : Decoder Job
decodeJobDetails =
    Json.Decode.map7 Job
        (field "id" int)
        (field "by" string)
        (field "score" int)
        (field "time" int)
        (field "title" string)
        (field "type" string)
        (maybe (field "url" string))



viewJobCard : Job -> Html msg
viewJobCard job =
    div [ class "job-article" ]
        [ div [ class "job-body" ]
            [ h2 [ class "job-company" ] [ text job.title ]
            , p [ class "job-details" ] [ text job.by ]
            , p [ class "job-date" ] [ text <| String.fromInt job.time ]
            ]
        ]

