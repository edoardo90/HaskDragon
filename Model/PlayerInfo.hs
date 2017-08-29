{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}

module Model.PlayerInfo (Player(..), newPlayer) where

import Model.GameMap

import Yesod
import Data.Aeson
import GHC.Generics


data Player = Player {name :: String, spheres :: [Item] } deriving (Show, Generic)

newPlayer :: String -> Player
newPlayer name = Player name []

instance ToJSON Player where
    toEncoding = genericToEncoding defaultOptions
instance FromJSON Player
