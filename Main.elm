module Main where

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

    Search sourceFile query ->
      tryThen Console.fatal <|
        loadSource sourceFile
          `andThen` \source -> loadDeps
          `andThen` (Task.fromResult << parseDeps)
          `andThen` \docPaths -> downloadDocs docPaths
          `andThen` \_ -> loadDocs docPaths
          `andThen` (Task.succeed << Oracle.search query source)
          `andThen` Console.log


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
parseDeps data =
  Ok []


downloadDocs : DocPaths -> Task String (List ())
downloadDocs =
  let test path =
        File.lstat path
          |> Task.mapError (\_ -> "")

      pull path =
        Http.get path
          |> Task.mapError (\_ -> "Could not download docs from " ++ path)

      write path data =
        File.write path data
          |> Task.mapError (\_ -> "Could not download docs to " ++ path)

      download path =
        test path.local
          `andThen` \_ -> Task.succeed ()
          `onError` \_ -> pull path.network
            `andThen` write path.local

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


tryThen : (x -> Task y a) -> Task x a -> Task y a
tryThen = flip Task.onError
