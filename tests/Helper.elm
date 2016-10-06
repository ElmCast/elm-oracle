module Helper exposing (..)

import Test exposing (..)
import Expect


testEq : String -> a -> a -> Test
testEq name a a' =
    test name <|
        \() -> Expect.equal a a'
