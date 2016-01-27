module Console
  ( log, error, fatal
  ) where

{-| Console
@docs log, error, fatal
-}

import Native.Console
import Task exposing (Task)


{-| Prints to stdout with a newline.
-}
log : a -> Task x ()
log value =
  Native.Console.log value


{-| Prints to stderr with a newline.
-}
error : a -> Task x ()
error value =
  Native.Console.error value


{-| Prints to stderr with a newline, then exits with an error code of 1.
-}
fatal : a -> Task x ()
fatal value =
  Native.Console.fatal value
