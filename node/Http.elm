module Http
  ( Error(..), get, serve, getURL, sendResponse, Request, Response
  ) where

{-|

@docs Error, Request, Response
@docs get, serve, getURL, sendResponse

-}

import Task exposing (Task)

import Native.Http

{-| Error
-}
type Error = NetworkError String


{-| Request
-}
type Request = Request


{-| Response
-}
type Response = Response


{-| get
-}
get : String -> Task Error String
get url =
  Native.Http.get url


{-| serve
-}
serve : Int -> (Request -> Response -> Task x a) -> Task x ()
serve prt taskFunction =
  Native.Http.serve prt taskFunction


{-| getURL
-}
getURL : Request -> String
getURL =
  Native.Http.get_url


{-| sendResponse
-}
sendResponse : Response -> String -> Task x ()
sendResponse response s =
  Task.succeed <| Native.Http.response_end response s
