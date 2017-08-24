{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
{-# LANGUAGE OverloadedStrings #-}

module Handlers.Map.Route where

import Yesod

data GameMap = GameMap

mkYesodSubData "GameMap" [parseRoutes|
/            GameMapHomeR GET
/people      PersonR GET POST
/cat         CatR POST
/cat-person  CatPersonR POST
|]
