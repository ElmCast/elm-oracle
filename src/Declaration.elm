module Declaration exposing (Declaration, parse)

{-| Parser for module declarations.

@docs Declaration, parse

-}

import List
import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Exposed exposing (Exposed(..))
import Import exposing (Import)


{-| Declaration
-}
type alias Declaration =
    { name : String
    , exposed : Exposed
    , comment : String
    }


pattern : Regex
pattern =
    regex "^(?:port\\s+|effect\\s+)?module\\s+([\\w+\\.?]+)(?:\\s+where\\s+{\\s+[\\s\\w=,]*})?(?:\\s+exposing\\s+\\(([\\s\\w,\\.]*)\\))?(?:\\s+{-\\|([\\s\\S]*?)-})?"


{-| Parse.
-}
parse : String -> Declaration
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
    in
        case List.head (List.map process matches) of
            Just ( name, exposed, comment ) ->
                Declaration name exposed comment

            Nothing ->
                Declaration "" None ""
