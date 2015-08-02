module Oracle where

import Json.Encode
import String
import Set
import Dict

import Import
import Package

search : String -> String -> List (String, String) -> String
search query source docs =
  let infos = collate (Import.parse source) (Package.parse docs) query
  in
      List.map encodeInfo infos
        |> Json.Encode.list
        |> Json.Encode.encode 0


type alias Info =
  { name : String
  , fullName : String
  , href : String
  , signature : String
  , comment : String
  }


encodeInfo : Info -> Json.Encode.Value
encodeInfo info =
  Json.Encode.object
    [ ("name", Json.Encode.string (info.name))
    , ("fullName", Json.Encode.string (info.fullName))
    , ("href", Json.Encode.string (info.href))
    , ("signature", Json.Encode.string (info.signature))
    , ("comment", Json.Encode.string (info.comment))
    ]


collate : Dict.Dict String Import.Import -> Package.Package -> String -> List Info
collate imports moduleList filterName =
  let getInfo modul =
        Maybe.map (moduleToDocs modul) (Dict.get modul.name imports)

      accept (token, info) =
        if String.startsWith filterName token
        then Just info
        else Nothing
  in
      List.filterMap getInfo moduleList
        |> List.concat
        |> List.filterMap accept


moduleToDocs : Package.Module -> Import.Import -> List (String, Info)
moduleToDocs modul { alias, exposed } =
  let dotToHyphen string =
        String.map (\c -> if c == '.' then '-' else c) string

      urlTo name =
        "http://package.elm-lang.org/packages/"
          ++ modul.packageName ++ "/latest/" ++ dotToHyphen modul.name ++ "#" ++ name

      nameToPair vname =
        let name = vname.name
            fullName = modul.name ++ "." ++ name
            info = Info name fullName (urlTo name) vname.signature vname.comment
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
            info = Info tag fullName (urlTo type') "" ""
        in
            [ (tag, info)
            , (fullName, info)
            ]
  in
      List.concatMap nameToPair (modul.values.aliases ++ modul.values.values)
        ++ List.concatMap (\(type', tags) -> List.concatMap (typeToPair type') tags) modul.values.types
