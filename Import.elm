module Imports exposing (Import, parse)

{-| Parser for imports.

@docs Import, parse

-}

import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Set
import String
import Dict exposing (Dict)
import Exposed exposing (Exposed(..))


{-| Import
-}
type alias Import =
    { alias : Maybe String
    , exposed : Exposed
    }


defaultImports : Dict String Import
defaultImports =
    Dict.fromList
        [ ( "Basics", Import Nothing Every )
        , ( "Debug", Import Nothing None )
        , ( "List", Import Nothing <| Some (Set.fromList [ "List", "::" ]) )
        , ( "Maybe", Import Nothing <| Some (Set.fromList [ "Maybe", "Just", "Nothing" ]) )
        , ( "Result", Import Nothing <| Some (Set.fromList [ "Result", "Ok", "Err" ]) )
        , ( "Platform", Import Nothing <| Some (Set.singleton "Program") )
        , ( "Platform.Cmd", Import Nothing <| Some (Set.fromList [ "Cmd", "!" ]) )
        , ( "Platform.Sub", Import Nothing <| Some (Set.singleton "Sub") )
        ]


pattern : Regex
pattern =
    regex "import\\s+([\\w+\\.?]+)(?:\\s+as\\s+(\\w+))?(?:\\s+exposing\\s+\\((.+)\\))?"


{-| Parse.
-}
parse : String -> Dict String Import
parse source =
    let
        matches =
            List.map .submatches (find All pattern source)

        process match =
            case match of
                name :: alias :: exposes :: [] ->
                    ( Maybe.withDefault "" name, Import alias (Exposed.parse exposes) )

                _ ->
                    Debug.crash "Shouldn't have gotten here processing imports."

        imports =
            List.map process matches
    in
        Dict.union (Dict.fromList imports) defaultImports
