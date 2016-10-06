module Import exposing (Import, database, parse)

{-| Parser for imports.

@docs Import, databse, parse

-}

import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Set
import String
import Dict exposing (Dict)
import Export exposing (Export(..))


{-| Import
-}
type alias Import =
    { name : String
    , alias : Maybe String
    , exports : Export
    }


defaultImports : Dict String Import
defaultImports =
    let
        build name exports =
            ( name, Import name Nothing exports )
    in
        Dict.fromList
            [ build "Basics" AllExport
            , build "Debug" NoneExport
            , build "List" (Export.parse "List, (::)")
            , build "Maybe" (Export.parse "Maybe(Just, Nothing)")
            , build "Result" (Export.parse "Result(Ok, Err)")
            , build "Platform" (Export.parse "Program")
            , build "Platform.Cmd" (Export.parse "Cmd, (!)")
            , build "Platform.Sub" (Export.parse "Sub")
            ]


{-| Database.
-}
database : List Import -> Dict String Import
database imports =
    let
        imports' =
            List.map (\import' -> ( import'.name, import' )) imports
    in
        Dict.union (Dict.fromList imports') defaultImports


pattern : Regex
pattern =
    regex "import\\s+([\\w+\\.?]+)(?:\\s+as\\s+(\\w+))?(?:\\s+exposing\\s*\\(((?:\\s*(?:\\w+|\\(.+\\)|\\w+\\(.+\\))\\s*,)*)\\s*((?:\\.\\.|\\w+|\\(.+\\)|\\w+\\(.+\\)))\\s*\\))?"


{-| Parse.
-}
parse : String -> List Import
parse source =
    let
        matches =
            List.map .submatches (find All pattern source)

        process match =
            case match of
                name :: alias :: exports :: exports' :: [] ->
                    Import
                        (Maybe.withDefault "" name)
                        alias
                        (Export.parse (Maybe.withDefault "" (Maybe.map2 (++) exports exports')))

                _ ->
                    Debug.crash "Shouldn't have gotten here processing imports."
    in
        List.map process matches
