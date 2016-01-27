module Path
  ( normalize, join, resolve, isAbsolute, relative
  , basename, extname, sep, delimiter
  ) where

{-| This module contains utilities for handling and transforming file paths.
Almost all these methods perform only string transformations.
The file system is not consulted to check whether paths are valid.

@docs normalize, join, resolve, isAbsolute, relative
@docs basename, extname, sep, delimiter

-}

import Native.Path

{-| Normalize a string path, taking care of '..' and '.' parts.

    normalize "/foo/bar//baz/asdf/quux/.." == "/foo/bar/baz/asdf"
-}
normalize : String -> String
normalize path =
  Native.Path.normalize path


{-| Join a list of paths together and normalize the resulting path.

    join ["/foo", "bar", "baz/asdf", "quux", ".."] == "/foo/bar/baz/asdf"
-}
join : List String -> String
join paths =
  Native.Path.join paths


{-| Resolves a list of paths to an absolute path.

  resolve ["foo/bar", "/tmp/file/", "..", "a/../subfile"] == "/tmp/subfile"

which is similar to

  cd foo/bar
  cd /tmp/file/
  cd ..
  cd a/../subfile
  pwd
-}
resolve : List String -> String
resolve paths =
  Native.Path.resolve paths


{-| Determines whether a path will always resolve to the same location,
regardless of the working directory.

  isAbsolute "/foo/bar" == true
  isAbsolute "/baz/.." == true
  isAbsolute "qux/" == false
  isAbsolute "." == false
-}
isAbsolute : String -> Bool
isAbsolute path =
  Native.Path.isAbsolute path


{-| Solve the relative path between two paths.

  relative "/data/orandea/test/aaa" "/data/orandea/impl/bbb" == "../../impl/bbb"
-}
relative : String -> String -> String
relative from to =
  Native.Path.relative from to


{-| Determine the directory name of a path.

  dirname "/foo/bar/baz/asdf/quux" == "/foo/bar/baz/asdf"
-}
dirname : String -> String
dirname path =
    Native.Path.dirname path


{-| Determine the last portion of a path.

  basename "/foo/bar/baz/asdf/quux.html" "" == "quux.html"
  basename "/foo/bar/baz/asdf/quux.html" ".html" == "quux"
-}
basename : String -> String -> String
basename path ext =
  Native.Path.basename path ext


{-| Determine the extension of the path.

  extname "index.html" == ".html"
  extname "index.coffee.md" == ".md"
  extname "index." == "."
  extname "index" == ""
-}
extname : String -> String
extname path =
  Native.Path.extname path


{-| The platform-specific file separator, '\\' or '/'.
-}
sep : String
sep =
  Native.Path.sep


{-| The platform-specific path delimiter, ; or ':'.
-}
delimiter : String
delimiter =
  Native.Path.delimiter
