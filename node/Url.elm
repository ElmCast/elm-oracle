module Url
  ( resolve, join
  ) where

{-| Url

@docs resolve, join

-}

import Native.Url
import String

{-| Resolve
-}
resolve : List String -> String
resolve paths =
  Native.Url.resolve paths


{-| Join
-}
join : List String -> String
join paths =
  String.join "/" paths
