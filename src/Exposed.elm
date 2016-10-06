module Exposed exposing (Exposed(..), parse)

{-| Parser for things exposed from modules.

@docs Exposed, parse

-}

import Set exposing (Set)
import String


{-| Exposed.
-}
type Exposed
    = None
    | Some (Set String)
    | Every


{-| Parse.
-}
parse : Maybe String -> Exposed
parse source =
    case Maybe.map ((List.map String.trim) << String.split ",") source of
        Nothing ->
            None

        Just [ ".." ] ->
            Every

        Just vars ->
            Some (Set.fromList vars)
