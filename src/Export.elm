module Export exposing (Export(..), Case(..), parse)

{-| Parser for things exposed from modules.

@docs Export, Case, parse

-}

import Regex exposing (Regex, find, HowMany(..), Match, regex)
import Set exposing (Set)
import String


{-| Case
-}
type Case
    = AllCase
    | NoneCase
    | SomeCase (List String)


toCase : List String -> Case
toCase cases =
    case cases of
        [] ->
            NoneCase

        [ ".." ] ->
            AllCase

        xs ->
            SomeCase xs


{-| Export
-}
type Export
    = AllExport
    | NoneExport
    | SubsetExport (List Export)
    | FunctionExport String
    | TypeExport String Case


isUpcase : String -> Bool
isUpcase s =
    let
        first =
            String.left 1 s
    in
        first == String.toUpper first


split : Maybe String -> Maybe (List String)
split s =
    Maybe.map ((List.map String.trim) << String.split ",") s


pattern : Regex
pattern =
    regex "(?:(\\w+)(?:\\(([^()]+)\\))?|\\(([^()]+)\\))"


{-| Parse.
-}
parse : String -> Export
parse source =
    if source == "" then
        NoneExport
    else if source == ".." then
        AllExport
    else
        let
            match source' =
                List.map .submatches (find All pattern source')

            process exports =
                case exports of
                    name :: types :: binop :: [] ->
                        let
                            name' =
                                Maybe.withDefault "" name

                            types' =
                                Maybe.withDefault [] (split types)

                            binop' =
                                Maybe.map FunctionExport binop
                        in
                            case binop of
                                Just binop' ->
                                    FunctionExport binop'

                                Nothing ->
                                    if isUpcase name' then
                                        TypeExport name' (toCase types')
                                    else
                                        FunctionExport name'

                    _ ->
                        Debug.crash "Shouldn't have gotten here processing exports."
        in
            SubsetExport (List.map process (match source))
