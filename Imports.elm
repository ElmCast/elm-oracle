module Imports exposing (parse, Import, Exposed(..))

import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Set
import String
import Dict exposing (Dict)


type Exposed
    = None
    | Some (Set.Set String)
    | Every


type alias Import =
    { alias : Maybe String, exposed : Exposed }


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


pattern =
    regex "import\\s+([\\w+\\.?]+)(?:\\s+as\\s+(\\w+))?(?:\\s+exposing\\s+\\((.+)\\))?"


parse source =
    let
        matches =
            List.map .submatches (find All pattern source)

        exposes e =
            case Maybe.map ((List.map String.trim) << String.split ",") e of
                Nothing ->
                    None

                Just [ ".." ] ->
                    Every

                Just vars ->
                    Some (Set.fromList vars)

        process match =
            case match of
                name :: alias :: exposed :: [] ->
                    ( Maybe.withDefault "" name, Import alias (exposes exposed) )

                _ ->
                    Debug.crash "Shouldn't have gotten here processing imports."

        imports =
            List.map process matches
    in
        Dict.union (Dict.fromList imports) defaultImports
