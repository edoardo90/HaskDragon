{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
{-# LANGUAGE OverloadedStrings #-}

module Handlers.Map.MapRoute where

import Yesod

data GameMap = GameMap

mkYesodSubData "GameMap" [parseRoutes|
/            GameMapHomeR GET POST
|]
