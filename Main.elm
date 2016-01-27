module Main where

import Json.Encode as Encode
import Json.Decode as Decode
import Task exposing (Task, andThen, onError)

import Console
import File
import Http
import Path
import Process
import Url

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
          --`andThen` \depsDocs -> getProjectDocs
          --`andThen` \projectDocs -> Task.succeed (projectDocs ++ depsDocs)
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


loadSource : String -> Task String String
loadSource path =
  File.read (Path.normalize path)
    `withError` ("Could not find the give source file: " ++ path)


loadDeps : Task String String
loadDeps =
  File.read (Path.resolve ["elm-stuff", "exact-dependencies.json"])
    `withError` "Dependencies file is missing. Perhaps you need to run `elm-package install`?"


type alias DocPaths = List { local : String, network : String }


parseDeps : String -> Result String DocPaths
parseDeps json =
  let deps = Decode.decodeString (Decode.keyValuePairs Decode.string) json
      buildDocPath (name, version) =
        let docFile = "documentation.json"
            local = Path.resolve ["elm-stuff", "packages", name, version, docFile]
            network = Url.join ["http://package.elm-lang.org", "packages", name, version, docFile]
        in
            { local = local, network = network }
  in
      case deps of
        Ok packages -> Ok <| List.map buildDocPath packages
        Err _ -> Err "Could not decode the dependencies file."


downloadDocs : DocPaths -> Task String (List ())
downloadDocs =
  let test path =
        (File.lstat path `andThen` \_ -> Task.succeed ()) `withError` path

      pull path =
        Http.get path `withError` ("Could not download docs from " ++ path)

      write path data =
        File.write path data `withError` ("Could not download docs to " ++ path)

      download path =
        test path.local
          `onError` \_ -> pull path.network `andThen` write path.local

  in
      Task.sequence << List.map download


loadDocs : DocPaths -> Task String (List (String, String))
loadDocs =
  let load path =
        (File.read path `andThen` (Task.succeed << (,) path))
          `withError` ("Could not load docs from " ++ path)
  in
      Task.sequence << List.map (.local >> load)


getProjectDocs : Task String (List (String, String))
getProjectDocs =
  let path = Path.resolve ["elm-stuff", "documentation.json"]

      generate =
        Process.exec ("elm-make Main.elm --docs " ++ path)
          `withError` "Failed to generate local project docs."

      load =
        File.read path
          `withError` "Failed to load local project docs."
  in
      generate
        `andThen` \_ -> load
        `andThen` \docs -> Task.succeed [(path, docs)]


emitError : String -> Task x ()
emitError message =
  let json =
        [Encode.object [ ("error", Encode.string (message)) ]]
          |> Encode.list
          |> Encode.encode 0
  in
    Console.fatal json


withError : Task x a -> y -> Task y a
withError task error =
  Task.mapError (\_ -> error) task


tryCatch : (x -> Task y a) -> Task x a -> Task y a
tryCatch = flip Task.onError
