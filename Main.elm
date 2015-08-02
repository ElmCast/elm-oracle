module Main where

import Task exposing (Task)

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
      loadSource sourceFile
        &> \source -> loadDeps
        &> Task.fromResult << parseDeps
        &> \docPaths -> downloadDocs docPaths
        &> \_ -> loadDocs docPaths
        &> Task.succeed << Oracle.search query source
        &> Console.log
        !> Console.fatal


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
        |> File.read >> Task.mapError errorMessage


loadDeps : Task String String
loadDeps =
  let errorMessage err =
        "Dependencies file is missing. Perhaps you need to run `elm-package install`?"
  in
      Path.resolve ["elm-stuff", "exact-dependencies.json"]
        |> File.read >> Task.mapError errorMessage


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
          &> \_ -> Task.succeed ()
          !> \_ -> pull path.network
            &> write path.local

  in
      Task.sequence << List.map download


loadDocs : DocPaths -> Task String (List (String, String))
loadDocs =
  let load path =
        File.read path
          &> Task.succeed << (,) path
          |> Task.mapError (\_ -> "Could not load docs from " ++ path)
  in
      Task.sequence << List.map (.local >> load)


(&>) : Task x a -> (a -> Task x b) -> Task x b
(&>) = Task.andThen


(!>) : Task x a -> (x -> Task y a) -> Task y a
(!>) = Task.onError


infixl 0 &>
infixl 0 !>
