module Main where

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
      loadSource sourceFile
        &> \source -> loadDeps
        &> Task.fromResult << parseDeps
        &> \docPaths -> filterExisting docPaths
        &> downloadDocs
        &> \_ -> loadDocs docPaths
        &> Oracle.search query source
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


--File.read (Path.resolve ["elm-stuff", "exact-dependencies.json"])

loadSource : String -> Task File.Error String
loadSource path =
  Path.normalize path |> File.read


loadDeps : Task File.Error String
loadDeps =
  Path.resolve ["elm-stuff", "exact-dependencies.json"] |> File.read


type alias DocPaths = List { local : String, network : String }


parseDeps : String -> Result String DocPaths
parseDeps =
  []


filterExisting : DocPaths -> Task File.Error DocPaths
filterExisting =
  taskFilter << List.map (File.lstat << .local)


downloadDocs : DocPaths -> Task File.Error ()
downloadDocs =
  Task.sequence << List.map (\path -> Http.get path.network &> File.write path.local)


loadDocs : DocPaths -> Task File.Error (List String)
loadDocs =
  Task.sequence << List.map (File.read << .local)


taskFilter : List (Task x a) -> Task x (List a)
taskFilter promises =
  let maybeCons f mx xs =
        case f mx of
          Just x -> x :: xs
          Nothing -> xs
  in
      case promises of
        [] ->
          Task.succeed []

        promise :: remainingTasks ->
          Task.map2 maybeCons (Task.toMaybe promise) (taskFilter remainingTasks)


(&>) : Task x a -> (a -> Task x b) -> Task x b
(&>) = Task.andThen


(!>) : Task x a -> (x -> Task y a) -> Task y a
(!>) = Task.onError


infixl 0 &>
infixl 0 !>
