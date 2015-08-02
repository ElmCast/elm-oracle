module Main where

import Json.Encode
import Task exposing (Task, andThen, onError)

import Console
import File
import Path
import Process

import Oracle

port main : Task x ()
port main =
  case parsedArgs of
    Help ->
      Console.log usage

    Search sourceFile query ->
      File.read sourceFile
        `andThen` \source -> File.read (Path.resolve ["elm-stuff", "exact-dependencies.json"])
        `andThen` Task.fromResult decodeDeps
        `andThen` \(docPaths, docUrls) -> filterExisting docPaths docUrls
        `andThen` downloadDocs
        `andThen` \_ -> loadDocs docPaths
        `andThen` Task.fromResult decodeDocs
        `andThen` Oracle.search query source
        `andThen` Task.fromResult encodeInfo
        `andThen` Console.log
          `onError` interpretError
            `andThen` Console.fatal


usage : String
usage = """elm-oracle 1.0.0

Usage: elm-oracle FILE query
  Query for information about a token in an Elm file.
  
Available options:
  -h,--help                    Show this help text."""


type Command = Help | Search String String


parsedArgs : Command
parsedArgs =
  case Process.args of
    "-h" :: xs -> Help
    "--help" :: xs -> Help
    x :: y :: [] -> Search x y
    _ -> Help


encodeInfo : Oracle.Info -> Json.Encode.Value
encodeInfo info =
  Json.Encode.object
    [ ("name", Json.Encode.string (info.name))
    , ("fullName", Json.Encode.string (info.fullName))
    , ("href", Json.Encode.string (info.href))
    , ("signature", Json.Encode.string (info.signature))
    , ("comment", Json.Encode.string (info.comment))
    ]
