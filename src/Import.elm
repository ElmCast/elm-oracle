module Import exposing (Import, database, parse)

{-| Parser for imports.

@docs Import, databse, parse

-}

import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Set
import String
import Dict exposing (Dict)
import Exposed exposing (Exposed(..))


{-| Import
-}
type alias Import =
    { name : String
    , alias : Maybe String
    , exposed : Exposed
    }


defaultImports : Dict String Import
defaultImports =
    let
        build name exposed =
            ( name, Import name Nothing exposed )
    in
        Dict.fromList
            [ build "Basics" Every
            , build "Debug" None
            , build "List" <| Some (Set.fromList [ "List", "::" ])
            , build "Maybe" <| Some (Set.fromList [ "Maybe", "Just", "Nothing" ])
            , build "Result" <| Some (Set.fromList [ "Result", "Ok", "Err" ])
            , build "Platform" <| Some (Set.singleton "Program")
            , build "Platform.Cmd" <| Some (Set.fromList [ "Cmd", "!" ])
            , build "Platform.Sub" <| Some (Set.singleton "Sub")
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
    regex "import\\s+([\\w+\\.?]+)(?:\\s+as\\s+(\\w+))?(?:\\s+exposing\\s*\\(((?:\\s*(?:\\w+|\\(.+\\))\\s*,)*)\\s*((?:\\.\\.|\\w+|\\(.+\\)))\\s*\\))?"


{-| Parse.
-}
parse : String -> List Import
parse source =
    let
        matches =
            List.map .submatches (find All pattern source)

        process match =
            case match of
                name :: alias :: exposes :: exposes' :: [] ->
                    Import
                        (Maybe.withDefault "" name)
                        alias
                        (Exposed.parse (Maybe.map2 (++) exposes exposes'))

                _ ->
                    Debug.crash "Shouldn't have gotten here processing imports."
    in
        List.map process matches
