module Module exposing (Module, parse)

{-| Parser for modules.

@docs Module, parse

-}

import List
import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Exposed exposing (Exposed(..))


{-| Module
-}
type alias Module =
    { name : String
    , exposed : Exposed
    , comment : String
    }


pattern : Regex
pattern =
    regex "^(?:port\\s+)?module\\s+([\\w+\\.?]+)(?:\\s+exposing\\s+\\((.+)\\))?(?:\\s+{-\\|([\\s\\S]*?)-})?"


{-| Parse.
-}
parse : String -> Maybe Module
parse source =
    let
        matches =
            List.map .submatches (find (AtMost 1) pattern source)

        process match =
            case match of
                name :: exposes :: comment :: [] ->
                    Module
                        (Maybe.withDefault "" name)
                        (Exposed.parse exposes)
                        (Maybe.withDefault "" comment)

                _ ->
                    Debug.crash "Shouldn't have gotten here processing a module."

        modules =
            List.map process matches
    in
        List.head modules
