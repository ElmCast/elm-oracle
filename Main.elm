module Main where

import Json.Encode
import Json.Decode
import Task exposing (Task, andThen, onError)

import Console
import File
import Http
import Path
import Process

import Oracle

port main : Task String ()
port main =
  case parsedArgs of
    Help ->
      Console.log usage

    Warn message ->
      emitError message

    Search sourceFile query ->
      tryCatch emitError <|
        loadSource sourceFile
          `andThen` \source -> loadDeps
          `andThen` \deps -> Task.fromResult (parseDeps deps)
          `andThen` \docPaths -> downloadDocs docPaths
          `andThen` \_ -> loadDocs docPaths
          `andThen` \docs -> Console.log (Oracle.search query source docs)


usage : String
usage = """elm-oracle 1.0.0

Usage: elm-oracle FILE query
  Query for information about a token in an Elm file.
  
Available options:
  -h,--help                    Show this help text."""


type Command = Help | Search String String | Warn String


parsedArgs : Command
parsedArgs =
  case Process.args of
    "-h" :: xs -> Help
    "--help" :: xs -> Help
    x1 :: x2 :: xs -> Search x1 x2
    x :: [] -> Warn "You did not supply a query."
    [] -> Warn "You did not supply a source file or query."
    _ -> Warn "Unknown error with your search."


emitError : String -> Task x ()
emitError message =
  let json =
        [Json.Encode.object [ ("error", Json.Encode.string (message)) ]]
          |> Json.Encode.list
          |> Json.Encode.encode 0
  in
    Console.fatal json


loadSource : String -> Task String String
loadSource path =
  let errorMessage err =
        "Could not find the given source file: " ++ path
  in
      Path.normalize path
        |> File.read
        |> Task.mapError errorMessage


loadDeps : Task String String
loadDeps =
  let errorMessage err =
        "Dependencies file is missing. Perhaps you need to run `elm-package install`?"
  in
      Path.resolve ["elm-stuff", "exact-dependencies.json"]
        |> File.read
        |> Task.mapError errorMessage


type alias DocPaths = List { local : String, network : String }


parseDeps : String -> Result String DocPaths
parseDeps json =
  let decoder = Json.Decode.keyValuePairs Json.Decode.string
      deps = Json.Decode.decodeString decoder json
      local = "elm-stuff"
      network = "http://package.elm-lang.org"
      buildDocPath (name, version) =
        let path = "/packages/" ++ name ++ "/" ++ version ++ "/documentation.json"
        in 
            { local = local ++ path, network = network ++ path }
  in
      case deps of
        Ok packages -> Ok <| List.map buildDocPath packages
        Err _ -> Err "Could not decode the dependencies file."


downloadDocs : DocPaths -> Task String (List ())
downloadDocs =
  let test path =
        (File.lstat path `andThen` \_ -> Task.succeed ())
          |> Task.mapError (\_ -> path)

      pull path =
        (Http.get path `andThen` \d -> Console.log d `andThen` \_ -> Task.succeed d)
          |> Task.mapError (\_ -> "Could not download docs from " ++ path)

      write path data =
        File.write path data
          |> Task.mapError (\_ -> "Could not download docs to " ++ path)

      download path =
        test path.local
          `onError` \_ -> pull path.network `andThen` write path.local

  in
      Task.sequence << List.map download


loadDocs : DocPaths -> Task String (List (String, String))
loadDocs =
  let load path =
        File.read path
          `andThen` (Task.succeed << (,) path)
            |> Task.mapError (\_ -> "Could not load docs from " ++ path)
  in
      Task.sequence << List.map (.local >> load)


tryCatch : (x -> Task y a) -> Task x a -> Task y a
tryCatch = flip Task.onError
