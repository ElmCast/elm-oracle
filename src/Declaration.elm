module Declaration exposing (Declaration, parse)

{-| Parser for module declarations.

@docs Declaration, parse

-}

import List
import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Export exposing (Export(..))
import Import exposing (Import)


{-| Declaration
-}
type alias Declaration =
    { name : String
    , exports : Export
    , comment : String
    }


pattern : Regex
pattern =
    --regex "^(?:port\\s+|effect\\s+)?module\\s+([\\w+\\.?]+)(?:\\s+where\\s+{\\s+[\\s\\w=,]*})?(?:\\s+exposing\\s+\\(([\\s\\w,\\.]*)\\))?(?:\\s+{-\\|([\\s\\S]*?)-})?"
    regex "^(?:port\\s+|effect\\s+)?module\\s+([\\w+\\.?]+)(?:\\s+where\\s+{\\s+[\\s\\w=,]*})?(?:\\s+exposing\\s*\\(((?:\\s*(?:\\w+|\\(.+\\)|\\w+\\(.+\\))\\s*,)*)\\s*((?:\\.\\.|\\w+|\\(.+\\)|\\w+\\(.+\\)))\\s*\\))?(?:\\s+{-\\|([\\s\\S]*?)-})?"


{-| Parse.
-}
parse : String -> Declaration
parse source =
    let
        matches =
            List.map .submatches (find (AtMost 1) pattern source)

        process match =
            case match of
                name :: exports :: exports' :: comment :: [] ->
                    ( Maybe.withDefault "" name
                    , Export.parse (Maybe.withDefault "" (Maybe.map2 (++) exports exports'))
                    , Maybe.withDefault "" comment
                    )

                _ ->
                    Debug.crash "Shouldn't have gotten here processing a module."
    in
        case List.head (List.map process matches) of
            Just ( name, exports, comment ) ->
                Declaration name exports comment

            Nothing ->
                Declaration "" NoneExport ""
