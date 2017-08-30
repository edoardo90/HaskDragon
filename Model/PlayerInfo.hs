{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings     #-}

module Model.PlayerInfo (Player(..), newPlayer, addItemToPlayer) where

import Model.GameMap (Item)

import Yesod
import Data.Aeson
import GHC.Generics
import Control.Lens hiding ((.=))

data Atom = Atom { _element :: String, _point :: Point } deriving (Show)
data Point = Point { _x :: Double, _y :: Double } deriving (Show)

makeLenses ''Atom
makeLenses ''Point

shiftAtomX :: Atom -> Atom
shiftAtomX = over (point . x) (+ 1)

data Player = Player {name :: String, _spheres :: [Item] } deriving (Show, Generic)

newPlayer :: String -> Player
newPlayer name = Player name []

makeLenses ''Player

addItemToPlayer ::  Item -> Player -> Player
addItemToPlayer item p@(Player name spheres) = if item `elem` spheres then p else Player name (item : spheres)

instance ToJSON Player where
  toJSON Player {..} = object
    [
        "name" .= name
      , "spheres" .= _spheres
    ]

instance FromJSON Player where
  parseJSON (Object pl) =
    Player <$> pl .: "name"
           <*> pl .: "spheres"
