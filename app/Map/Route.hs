{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
module Map.Route where

import Yesod

data GameMap = GameMap

mkYesodSubData "GameMap" [parseRoutes|
/ GameMapHomeR GET
|]
