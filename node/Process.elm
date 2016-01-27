module Process
  ( args, argv, execPath, execArgv, exec, exit, pid
  , version
  ) where

{-| Process

@docs args, argv, execPath, execArgv

@docs exec

@docs exit, pid

@docs version

-}

import Native.Process
import Basics exposing (..)
import Task exposing (Task)

{-| A List containing the command line arguments.
The first element will be 'node', the second element will be the name of the JavaScript file.
The next elements will be any additional command line arguments.
-}
argv : List String
argv =
  Native.Process.argv


{-| A List containing only the additional command line arguments.
-}
args : List String
args =
  List.drop 2 Native.Process.argv


{-| The absolute pathname of the executable that started the process.
-}
execPath : String
execPath =
  Native.Process.execPath


{-| The set of node-specific command line options from the executable that started the process.
-}
execArgv : List String
execArgv =
  Native.Process.execArgv


{-| Run a command in a shell.
-}
exec : String -> Task String String
exec command =
  Native.Process.exec command


{-| Ends the process with the specified code.
-}
exit : Int -> Task x ()
exit code =
  Native.Process.exit code


{-| The PID of the process.
-}
pid : Int
pid =
  Native.Process.pid


{-| A compiled-in property that exposes NODE_VERSION.
-}
version : String
version =
  Native.Process.version
