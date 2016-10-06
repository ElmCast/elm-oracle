module Module exposing (Module, parse)

{-| Parser for modules.

@docs Module, parse

-}

import List
import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Exposed exposing (Exposed(..))
import Import exposing (Import)


{-| Module
-}
type alias Module =
    { name : String
    , exposed : Exposed
    , comment : String
    , imports : List Import
    }


pattern : Regex
pattern =
    regex "^(?:port\\s+|effect\\s+)?module\\s+([\\w+\\.?]+)(?:\\s+where\\s+{\\s+[\\s\\w=,]*})?(?:\\s+exposing\\s+\\(([\\s\\w,\\.]*)\\))?(?:\\s+{-\\|([\\s\\S]*?)-})?"


{-| Parse.
-}
parse : String -> Module
parse source =
    let
        matches =
            List.map .submatches (find (AtMost 1) pattern source)

        process match =
            case match of
                name :: exposes :: comment :: [] ->
                    ( Maybe.withDefault "" name
                    , Exposed.parse exposes
                    , Maybe.withDefault "" comment
                    )

                _ ->
                    Debug.crash "Shouldn't have gotten here processing a module."

        imports =
            Import.parse source
    in
        case List.head (List.map process matches) of
            Just ( name, exposed, comment ) ->
                Module name exposed comment imports

            Nothing ->
                Module "" None "" imports
