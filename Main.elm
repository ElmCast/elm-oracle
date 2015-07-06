module Main where

import Dict
import Maybe
import Set
import String
import Json.Encode

import Import
import Package
import Native.Main

-- Inputs
port code : String
port docs : List (String, String)
port token : String

-- Outputs
port response : String
port response = process

-- Main
process =
    let imports = Import.parse code
        packages = Package.parse docs
        data = collate imports packages
        infos = Maybe.withDefault [] (Dict.get token data)
    in
        List.map encodeInfo infos
            |> Json.Encode.list
            |> Json.Encode.encode 0


encodeInfo info =
    Json.Encode.object
        [ ("name", Json.Encode.string (info.name))
        , ("href", Json.Encode.string (info.href))
        , ("signature", Json.Encode.string (info.signature))
        , ("comment", Json.Encode.string (info.comment))
        ]


type alias Docs = Dict.Dict String (List Info)


type alias Info =
    { name : String
    , href : String
    , signature : String
    , comment : String
    }


collate : Dict.Dict String Import.Import -> Package.Package -> Docs
collate imports moduleList =
  let getInfo modul =
          Maybe.map (moduleToDocs modul) (Dict.get modul.name imports)

      insert (token, info) dict =
          Dict.update token (\value -> Just (info :: Maybe.withDefault [] value)) dict
  in
      List.filterMap getInfo moduleList
        |> List.concat
        |> List.foldl insert Dict.empty


moduleToDocs : Package.Module -> Import.Import -> List (String, Info)
moduleToDocs modul { alias, exposed } =
  let urlTo name =
        "http://package.elm-lang.org/packages/"
        ++ modul.packageName ++ "/latest/" ++ dotToHyphen modul.name ++ "#" ++ name


      nameToPair vname =
        let name = vname.name
            fullName = modul.name ++ "." ++ name
            info = Info fullName (urlTo name) vname.signature vname.comment
            localName = Maybe.withDefault modul.name alias ++ "." ++ name
            pairs = [(localName, info)]
        in
            case exposed of
              Import.None ->
                  pairs

              Import.Some set ->
                  if Set.member name set then (name, info) :: pairs else pairs

              Import.Every ->
                  (name, info) :: pairs

      typeToPair type' tag =
        let fullName = modul.name ++ "." ++ tag
            info = Info fullName (urlTo type') "" ""
        in
            [ (tag, info)
            , (fullName, info)
            ]
  in
      List.concatMap nameToPair (modul.values.aliases ++ modul.values.values)
      ++ List.concatMap (\(type', tags) -> List.concatMap (typeToPair type') tags) modul.values.types


dotToHyphen : String -> String
dotToHyphen string =
  String.map (\c -> if c == '.' then '-' else c) string
