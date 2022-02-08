module Job exposing (..)

import Html exposing (Html, a, div, h2, p, text)
import Html.Attributes exposing (class, href)
import Json.Decode exposing (Decoder, field, int, maybe, string)
import Time


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


viewUrl : Job -> Html msg
viewUrl job =
    case job.url of
        Just url ->
            a [ class "job-details", href url ] [ text url ]

        Nothing ->
            p [ class "job-details" ] [ text "no link found" ]


viewTime : Job -> Html msg
viewTime job =
    let
        posixDate =
            Time.millisToPosix <| job.time * 1000

        dateYear =
            String.fromInt <| Time.toYear Time.utc posixDate

        dateMonth =
            monthNumber posixDate

        dateDay =
            String.padLeft 2 '0' <| String.fromInt <| Time.toDay Time.utc posixDate

        dateRepr =
            dateYear ++ "/" ++ dateMonth ++ "/" ++ dateDay
    in
    p [ class "job-date" ]
        [ text dateRepr ]


monthNumber : Time.Posix -> String
monthNumber posixDate =
    case Time.toMonth Time.utc posixDate of
        Time.Jan ->
            "01"

        Time.Feb ->
            "02"

        Time.Mar ->
            "03"

        Time.Apr ->
            "04"

        Time.May ->
            "05"

        Time.Jun ->
            "06"

        Time.Jul ->
            "07"

        Time.Aug ->
            "08"

        Time.Sep ->
            "09"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"


viewTitle : Job -> Html msg
viewTitle job =
    h2 [ class "job-company" ]
        [ text job.title ]


viewJob : Job -> Html msg
viewJob job =
    div [ class "job-article" ]
        [ div [ class "job-body" ]
            [ viewTitle job
            , viewUrl job
            , viewTime job
            ]
        ]
