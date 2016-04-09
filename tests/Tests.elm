module Tests (..) where

import ElmTest exposing (..)


all : Test
all =
  suite
    "A Test Suite"
    [ test "elm-oracle is awesome" (assert True)
    ]
