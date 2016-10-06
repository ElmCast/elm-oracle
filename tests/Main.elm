port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import Declarations
import Imports


main : Program Value
main =
    run emit all


all : Test
all =
    describe "Test Suite"
        [ Declarations.all
        , Imports.all
        ]


port emit : ( String, Value ) -> Cmd msg
