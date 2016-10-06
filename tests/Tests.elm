module Tests exposing (..)

import Test exposing (..)
import Helper exposing (..)
import Expect
import Set
import String
import Exposed exposing (Exposed(..))
import Module exposing (Module)


plain : Test
plain =
    testEq "plain"
        (Module.parse "module Test")
        (Module "Test" None "" [])


plainExposingAll : Test
plainExposingAll =
    testEq "plain exposing all"
        (Module.parse "module Test exposing (..)")
        (Module "Test" Every "" [])


plainExposingOne : Test
plainExposingOne =
    testEq "plain exposing one"
        (Module.parse "module Test exposing (a)")
        (Module "Test" (Some <| Set.fromList [ "a" ]) "" [])


plainExposingMany : Test
plainExposingMany =
    testEq "plain exposing many"
        (Module.parse "module Test exposing (a, b)")
        (Module "Test" (Some <| Set.fromList [ "a", "b" ]) "" [])


plainExposingManyMultiline : Test
plainExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Module.parse "module Test exposing\n    ( a\n    , b\n    )\n")
        (Module "Test" (Some <| Set.fromList [ "a", "b" ]) "" [])


plainPort : Test
plainPort =
    testEq "plain port"
        (Module.parse "port module Test")
        (Module "Test" None "" [])


portExposingAll : Test
portExposingAll =
    test "port exposing all" <|
        \() ->
            Expect.equal (Module.parse "port module Test exposing (..)") (Module "Test" Every "" [])


portExposingOne : Test
portExposingOne =
    testEq "port exposing one"
        (Module.parse "port module Test exposing (a)")
        (Module "Test" (Some <| Set.fromList [ "a" ]) "" [])


portExposingMany : Test
portExposingMany =
    testEq "port exposing many"
        (Module.parse "port module Test exposing (a, b)")
        (Module "Test" (Some <| Set.fromList [ "a", "b" ]) "" [])


portExposingManyMultiline : Test
portExposingManyMultiline =
    testEq "port exposing many multiline"
        (Module.parse "port module Test exposing\n    ( a\n    , b\n    )\n")
        (Module "Test" (Some <| Set.fromList [ "a", "b" ]) "" [])


plainEffect : Test
plainEffect =
    testEq "plain effect"
        (Module.parse "effect module Test where { command = MyCmd }")
        (Module "Test" None "" [])


effectExposingAll : Test
effectExposingAll =
    testEq "effect exposing all"
        (Module.parse "effect module Test where { command = MyCmd } exposing (..)")
        (Module "Test" Every "" [])


effectExposingOne : Test
effectExposingOne =
    testEq "effect exposing one"
        (Module.parse "effect module Test where { command = MyCmd } exposing (a)")
        (Module "Test" (Some <| Set.fromList [ "a" ]) "" [])


effectExposingMany : Test
effectExposingMany =
    testEq "plain exposing many"
        (Module.parse "effect module Test where { command = MyCmd } exposing (a, b)")
        (Module "Test" (Some <| Set.fromList [ "a", "b" ]) "" [])


effectExposingManyMultiline : Test
effectExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Module.parse "port module Test where { command = MyCmd } exposing\n    ( a\n    , b\n    )\n")
        (Module "Test" (Some <| Set.fromList [ "a", "b" ]) "" [])


all : Test
all =
    describe "Modules"
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
