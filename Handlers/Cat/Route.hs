{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
{-# LANGUAGE OverloadedStrings #-}

module Handlers.Cat.Route where

import Yesod

data GameCat = GameCat

mkYesodSubData "GameCat" [parseRoutes|
/            GameCatHomeR GET
/people      PersonR GET POST
/cat         CatR POST
/cat-person  CatPersonR POST
|]
