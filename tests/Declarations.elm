module Declarations exposing (..)

import Test exposing (..)
import Helper exposing (..)
import Expect
import Set
import String
import Exposed exposing (Exposed(..))
import Declaration exposing (Declaration)


plain : Test
plain =
    testEq "plain"
        (Declaration.parse "module Test")
        (Declaration "Test" None "")


plainExposingAll : Test
plainExposingAll =
    testEq "plain exposing all"
        (Declaration.parse "module Test exposing (..)")
        (Declaration "Test" Every "")


plainExposingOne : Test
plainExposingOne =
    testEq "plain exposing one"
        (Declaration.parse "module Test exposing (a)")
        (Declaration "Test" (Some <| Set.fromList [ "a" ]) "")


plainExposingMany : Test
plainExposingMany =
    testEq "plain exposing many"
        (Declaration.parse "module Test exposing (a, b)")
        (Declaration "Test" (Some <| Set.fromList [ "a", "b" ]) "")


plainExposingManyMultiline : Test
plainExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Declaration.parse "module Test exposing\n    ( a\n    , b\n    )\n")
        (Declaration "Test" (Some <| Set.fromList [ "a", "b" ]) "")


plainPort : Test
plainPort =
    testEq "plain port"
        (Declaration.parse "port module Test")
        (Declaration "Test" None "")


portExposingAll : Test
portExposingAll =
    testEq "port exposing all"
        (Declaration.parse "port module Test exposing (..)")
        (Declaration "Test" Every "")


portExposingOne : Test
portExposingOne =
    testEq "port exposing one"
        (Declaration.parse "port module Test exposing (a)")
        (Declaration "Test" (Some <| Set.fromList [ "a" ]) "")


portExposingMany : Test
portExposingMany =
    testEq "port exposing many"
        (Declaration.parse "port module Test exposing (a, b)")
        (Declaration "Test" (Some <| Set.fromList [ "a", "b" ]) "")


portExposingManyMultiline : Test
portExposingManyMultiline =
    testEq "port exposing many multiline"
        (Declaration.parse "port module Test exposing\n    ( a\n    , b\n    )\n")
        (Declaration "Test" (Some <| Set.fromList [ "a", "b" ]) "")


plainEffect : Test
plainEffect =
    testEq "plain effect"
        (Declaration.parse "effect module Test where { command = MyCmd }")
        (Declaration "Test" None "")


effectExposingAll : Test
effectExposingAll =
    testEq "effect exposing all"
        (Declaration.parse "effect module Test where { command = MyCmd } exposing (..)")
        (Declaration "Test" Every "")


effectExposingOne : Test
effectExposingOne =
    testEq "effect exposing one"
        (Declaration.parse "effect module Test where { command = MyCmd } exposing (a)")
        (Declaration "Test" (Some <| Set.fromList [ "a" ]) "")


effectExposingMany : Test
effectExposingMany =
    testEq "plain exposing many"
        (Declaration.parse "effect module Test where { command = MyCmd } exposing (a, b)")
        (Declaration "Test" (Some <| Set.fromList [ "a", "b" ]) "")


effectExposingManyMultiline : Test
effectExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Declaration.parse "port module Test where { command = MyCmd } exposing\n    ( a\n    , b\n    )\n")
        (Declaration "Test" (Some <| Set.fromList [ "a", "b" ]) "")


all : Test
all =
    describe "Declarations"
        [ plain
        , plainExposingAll
        , plainExposingOne
        , plainExposingMany
        , plainExposingManyMultiline
        , plainPort
        , portExposingAll
        , portExposingOne
        , portExposingMany
        , portExposingManyMultiline
        , plainEffect
        , effectExposingAll
        , effectExposingOne
        , effectExposingMany
        , effectExposingManyMultiline
        ]
