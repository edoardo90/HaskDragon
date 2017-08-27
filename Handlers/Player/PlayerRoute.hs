{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns      #-}

module Handlers.Player.PlayerRoute where

import Yesod
import Data.Text as T

data GamePlayer = GamePlayer

type PlayerName = Text
type SphereId = Int

mkYesodSubData "GamePlayer" [parseRoutes|
/#PlayerName/join               GamePlayerHomeR    POST
/#PlayerName/collect/#SphereId  GamePlayerCollectR POST 
|]
