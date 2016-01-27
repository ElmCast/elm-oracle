module File
  ( Error(..), read, write, lstat
  ) where

{-| File

@docs Error
@docs read
@docs lstat
@docs write

-}

import Native.File
import Task exposing (Task)

{-| Error
-}
type Error = ReadError String | WriteError String


{-| Read a file.
-}
read : String -> Task Error String
read path =
  Native.File.read path


{-| Write a file.
-}
write : String -> String -> Task Error ()
write path data =
  Native.File.write path data


{-| Stat
-}
type alias Stat = {}


{-| lstat
-}
lstat : String -> Task Error Stat
lstat path =
  Native.File.lstat path
