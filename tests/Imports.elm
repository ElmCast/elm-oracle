module Imports exposing (..)

import Test exposing (..)
import Helper exposing (..)
import Export exposing (Export(..), Case(..))
import Import exposing (Import)


plain : Test
plain =
    testEq "plain"
        (Import.parse "import Test")
        ([ Import "Test" Nothing NoneExport ])


plainExposingAll : Test
plainExposingAll =
    testEq "plain exposing all"
        (Import.parse "import Test exposing (..)")
        ([ Import "Test" Nothing AllExport ])


plainExposingBinop : Test
plainExposingBinop =
    testEq "plain exposing binop"
        (Import.parse "import Test exposing ((::))")
        ([ Import "Test" Nothing (SubsetExport [ FunctionExport "::" ]) ])


plainExposingType : Test
plainExposingType =
    testEq "plain exposing type"
        (Import.parse "import Test exposing (A)")
        ([ Import "Test" Nothing (SubsetExport [ TypeExport "A" NoneCase ]) ])


plainExposingTypeAll : Test
plainExposingTypeAll =
    testEq "plain exposing type all"
        (Import.parse "import Test exposing (A(..))")
        ([ Import "Test" Nothing (SubsetExport [ TypeExport "A" AllCase ]) ])


plainExposingTypeOne : Test
plainExposingTypeOne =
    testEq "plain exposing type all"
        (Import.parse "import Test exposing (A(B))")
        ([ Import "Test" Nothing (SubsetExport [ TypeExport "A" (SomeCase [ "B" ]) ]) ])


plainExposingTypeMany : Test
plainExposingTypeMany =
    testEq "plain exposing type many"
        (Import.parse "import Test exposing (A(B, C))")
        ([ Import "Test" Nothing (SubsetExport [ TypeExport "A" (SomeCase [ "B", "C" ]) ]) ])


plainExposingTypeManyMultiline : Test
plainExposingTypeManyMultiline =
    testEq "plain exposing type many multiline"
        (Import.parse "import Test exposing\n    ( a\n    , A(B, C)\n    )\n")
        ([ Import "Test" Nothing (SubsetExport [ FunctionExport "a", TypeExport "A" (SomeCase [ "B", "C" ]) ]) ])


plainExposingOne : Test
plainExposingOne =
    testEq "plain exposing one"
        (Import.parse "import Test exposing (a)")
        ([ Import "Test" Nothing (SubsetExport [ FunctionExport "a" ]) ])


plainExposingMany : Test
plainExposingMany =
    testEq "plain exposing many"
        (Import.parse "import Test exposing (a, b)")
        ([ Import "Test" Nothing (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) ])


plainExposingManyMultiline : Test
plainExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Import.parse "import Test exposing\n    ( a\n    , b\n    )\n")
        ([ Import "Test" Nothing (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) ])


plainAs : Test
plainAs =
    testEq "plain as"
        (Import.parse "import Test as Test1")
        ([ Import "Test" (Just "Test1") NoneExport ])


asExposingAll : Test
asExposingAll =
    testEq "as exposing all"
        (Import.parse "import Test as Test1 exposing (..)")
        ([ Import "Test" (Just "Test1") AllExport ])


asExposingOne : Test
asExposingOne =
    testEq "as exposing one"
        (Import.parse "import Test as Test1 exposing (a)")
        ([ Import "Test" (Just "Test1") (SubsetExport [ FunctionExport "a" ]) ])


asExposingMany : Test
asExposingMany =
    testEq "as exposing many"
        (Import.parse "import Test as Test1 exposing (a, b)")
        ([ Import "Test" (Just "Test1") (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) ])


asExposingManyMultiline : Test
asExposingManyMultiline =
    testEq "as exposing many multiline"
        (Import.parse "import Test as Test1 exposing\n    ( a\n    , b\n    )\n")
        ([ Import "Test" (Just "Test1") (SubsetExport [ FunctionExport "a", FunctionExport "b" ]) ])


all : Test
all =
    describe "Imports"
        [ plain
        , plainExposingAll
        , plainExposingBinop
        , plainExposingType
        , plainExposingTypeAll
        , plainExposingTypeOne
        , plainExposingTypeMany
        , plainExposingTypeManyMultiline
        , plainExposingOne
        , plainExposingMany
        , plainExposingManyMultiline
        , plainAs
        , asExposingAll
        , asExposingOne
        , asExposingMany
        , asExposingManyMultiline
        ]
