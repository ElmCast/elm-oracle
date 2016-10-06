module Declarations exposing (..)

import Test exposing (..)
import Helper exposing (..)
import Export exposing (Export(..), Case(..))
import Declaration exposing (Declaration)


plain : Test
plain =
    testEq "plain"
        (Declaration.parse "module Test")
        (Declaration "Test" NoneExport "")


plainExposingAll : Test
plainExposingAll =
    testEq "plain exposing all"
        (Declaration.parse "module Test exposing (..)")
        (Declaration "Test" AllExport "")


plainExposingBinop : Test
plainExposingBinop =
    testEq "plain exposing binop"
        (Declaration.parse "module Test exposing ((::))")
        (Declaration "Test" (SubsetExport [ FunctionExport "::" ]) "")


plainExposingOne : Test
plainExposingOne =
    testEq "plain exposing one"
        (Declaration.parse "module Test exposing (a)")
        (Declaration "Test" (SubsetExport [ FunctionExport "a" ]) "")


plainExposingMany : Test
plainExposingMany =
    testEq "plain exposing many"
        (Declaration.parse "module Test exposing (a, b)")
        (Declaration "Test" (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) "")


plainExposingManyMultiline : Test
plainExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Declaration.parse "module Test exposing\n    ( a\n    , b\n    )\n")
        (Declaration "Test" (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) "")


plainExposingType : Test
plainExposingType =
    testEq "plain exposing type"
        (Declaration.parse "module Test exposing (A)")
        (Declaration "Test" (SubsetExport [ TypeExport "A" NoneCase ]) "")


plainExposingTypeAll : Test
plainExposingTypeAll =
    testEq "plain exposing type all"
        (Declaration.parse "module Test exposing (A(..))")
        (Declaration "Test" (SubsetExport [ TypeExport "A" AllCase ]) "")


plainExposingTypeOne : Test
plainExposingTypeOne =
    testEq "plain exposing type one"
        (Declaration.parse "module Test exposing (A(B))")
        (Declaration "Test" (SubsetExport [ TypeExport "A" (SomeCase [ "B" ]) ]) "")


plainExposingTypeMany : Test
plainExposingTypeMany =
    testEq "plain exposing type many"
        (Declaration.parse "module Test exposing (A(B, C))")
        (Declaration "Test" (SubsetExport [ TypeExport "A" (SomeCase [ "B", "C" ]) ]) "")


plainPort : Test
plainPort =
    testEq "plain port"
        (Declaration.parse "port module Test")
        (Declaration "Test" NoneExport "")


portExposingAll : Test
portExposingAll =
    testEq "port exposing all"
        (Declaration.parse "port module Test exposing (..)")
        (Declaration "Test" AllExport "")


portExposingOne : Test
portExposingOne =
    testEq "port exposing one"
        (Declaration.parse "port module Test exposing (a)")
        (Declaration "Test" (SubsetExport [ FunctionExport "a" ]) "")


portExposingMany : Test
portExposingMany =
    testEq "port exposing many"
        (Declaration.parse "port module Test exposing (a, b)")
        (Declaration "Test" (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) "")


portExposingManyMultiline : Test
portExposingManyMultiline =
    testEq "port exposing many multiline"
        (Declaration.parse "port module Test exposing\n    ( a\n    , b\n    )\n")
        (Declaration "Test" (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) "")


plainEffect : Test
plainEffect =
    testEq "plain effect"
        (Declaration.parse "effect module Test where { command = MyCmd }")
        (Declaration "Test" NoneExport "")


effectExposingAll : Test
effectExposingAll =
    testEq "effect exposing all"
        (Declaration.parse "effect module Test where { command = MyCmd } exposing (..)")
        (Declaration "Test" AllExport "")


effectExposingOne : Test
effectExposingOne =
    testEq "effect exposing one"
        (Declaration.parse "effect module Test where { command = MyCmd } exposing (a)")
        (Declaration "Test" (SubsetExport [ FunctionExport "a" ]) "")


effectExposingMany : Test
effectExposingMany =
    testEq "plain exposing many"
        (Declaration.parse "effect module Test where { command = MyCmd } exposing (a, b)")
        (Declaration "Test" (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) "")


effectExposingManyMultiline : Test
effectExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Declaration.parse "port module Test where { command = MyCmd } exposing\n    ( a\n    , b\n    )\n")
        (Declaration "Test" (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) "")


all : Test
all =
    describe "Declarations"
        [ plain
        , plainExposingAll
        , plainExposingBinop
        , plainExposingOne
        , plainExposingMany
        , plainExposingManyMultiline
        , plainExposingType
        , plainExposingTypeAll
        , plainExposingTypeOne
        , plainExposingTypeMany
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
