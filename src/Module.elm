module Module exposing (Module, parse)

{-| Parser for modules.

@docs Module, parse

-}

import Declaration exposing (Declaration)
import Import exposing (Import)


{-| Module
-}
type alias Module =
    { delcaration : Declaration
    , imports : List Import
    }


{-| Parse.
-}
parse : String -> Module
parse source =
    Module (Declaration.parse source) (Import.parse source)
