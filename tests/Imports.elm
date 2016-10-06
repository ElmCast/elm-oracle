module Imports exposing (..)

import Test exposing (..)
import Helper exposing (..)
import Expect
import Set
import String
import Exposed exposing (Exposed(..))
import Import exposing (Import)


plain : Test
plain =
    testEq "plain"
        (Import.parse "import Test")
        ([ Import "Test" Nothing None ])


plainExposingAll : Test
plainExposingAll =
    testEq "plain exposing all"
        (Import.parse "import Test exposing (..)")
        ([ Import "Test" Nothing Every ])


plainExposingBinop : Test
plainExposingBinop =
    testEq "plain exposing binop"
        (Import.parse "import Test exposing ((::))")
        ([ Import "Test" Nothing (Some <| Set.fromList [ "(::)" ]) ])


plainExposingOne : Test
plainExposingOne =
    testEq "plain exposing one"
        (Import.parse "import Test exposing (a)")
        ([ Import "Test" Nothing (Some <| Set.fromList [ "a" ]) ])


plainExposingMany : Test
plainExposingMany =
    testEq "plain exposing many"
        (Import.parse "import Test exposing (a, b)")
        ([ Import "Test" Nothing (Some <| Set.fromList [ "a", "b" ]) ])


plainExposingManyMultiline : Test
plainExposingManyMultiline =
    testEq "plain exposing many multiline"
        (Import.parse "import Test exposing\n    ( a\n    , b\n    )\n")
        ([ Import "Test" Nothing (Some <| Set.fromList [ "a", "b" ]) ])


plainAs : Test
plainAs =
    testEq "plain as"
        (Import.parse "import Test as Test1")
        ([ Import "Test" (Just "Test1") None ])


asExposingAll : Test
asExposingAll =
    testEq "as exposing all"
        (Import.parse "import Test as Test1 exposing (..)")
        ([ Import "Test" (Just "Test1") Every ])


asExposingOne : Test
asExposingOne =
    testEq "as exposing one"
        (Import.parse "import Test as Test1 exposing (a)")
        ([ Import "Test" (Just "Test1") (Some <| Set.fromList [ "a" ]) ])


asExposingMany : Test
asExposingMany =
    testEq "as exposing many"
        (Import.parse "import Test as Test1 exposing (a, b)")
        ([ Import "Test" (Just "Test1") (Some <| Set.fromList [ "a", "b" ]) ])


asExposingManyMultiline : Test
asExposingManyMultiline =
    testEq "as exposing many multiline"
        (Import.parse "import Test as Test1 exposing\n    ( a\n    , b\n    )\n")
        ([ Import "Test" (Just "Test1") (Some <| Set.fromList [ "a", "b" ]) ])


all : Test
all =
    describe "Imports"
        [ plain
        , plainExposingAll
        , plainExposingBinop
        , plainExposingOne
        , plainExposingMany
        , plainExposingManyMultiline
        , plainAs
        , asExposingAll
        , asExposingOne
        , asExposingMany
        , asExposingManyMultiline
        ]
