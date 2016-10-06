port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import Declarations


main : Program Value
main =
    run emit all


all : Test
all =
    describe "Test Suite" [ Declarations.all ]


port emit : ( String, Value ) -> Cmd msg
