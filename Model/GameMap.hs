{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE DeriveGeneric #-}

module Model.GameMap (Item, Map(..), Board(..), BoardBound, boardToBBound ) where

import Yesod
import Data.Aeson
import GHC.Generics

--import Prelude hiding (id)
import Control.Monad (mzero)
import Data.List (minimumBy, maximumBy)
import Data.Function (on)

-- tools
import Data.Maybe (fromMaybe)
import qualified Data.ByteString.Lazy.Char8 as L
import           Data.Text                  (Text)

--persistence
import qualified Tool.StrTools as Str

data Item = Item {id :: Int, latitude :: Double, longitude :: Double} deriving (Show)
newtype Map = Map {spheres:: [Item]} deriving (Show)

data Board = Board {map :: Map, time :: Time} deriving (Generic, Show)
data Time = Time { start :: Int, end :: Int}  deriving (Generic, Show)


data BoardBound = BoardBound {bmap :: Map,
                              btime :: Time,
                              boundingBox :: BoundingBox} deriving (Show)

boardToBBound :: Board -> BoardBound
boardToBBound (Board m t) = BoardBound m t (calcBoundingBox m)

calcBoundingBox :: Map -> BoundingBox
calcBoundingBox (Map sp) =
  let latMin = latitude $ minimumBy (compare `on` latitude) sp
      latMax = latitude $ maximumBy (compare `on` latitude) sp
      longMin = longitude $ minimumBy (compare `on` longitude) sp
      longMax = longitude $ maximumBy (compare `on` longitude) sp
  in  BoundingBox (BCoordsMin latMin longMin) (BCoordsMax latMax longMax)

data BoundingBox = BoundingBox {bmin :: BCoordsMin, bmax:: BCoordsMax} deriving (Show)
data BCoordsMin = BCoordsMin {minLatitude:: Double, minLongitude :: Double} deriving (Show)
data BCoordsMax = BCoordsMax {maxLatitude:: Double, maxLongitude :: Double} deriving (Show)

instance ToJSON BoundingBox where
  toJSON BoundingBox {..} = object
    [
       "min" .= bmin
     , "max" .= bmax
    ]

instance FromJSON BoundingBox where
  parseJSON (Object bb) =
    BoundingBox <$> bb .: "min"
                <*> bb .: "max"

instance ToJSON BCoordsMin where
  toJSON BCoordsMin {..} = object
    [
        "latitude" .= minLatitude
      , "longitude" .= minLongitude
    ]

instance FromJSON BCoordsMin where
  parseJSON (Object bl) =
    BCoordsMin <$> bl .: "latitude"
            <*> bl .: "longitude"

instance ToJSON BCoordsMax where
  toJSON BCoordsMax {..} = object
    [
        "latitude" .= maxLatitude
      , "longitude" .= maxLongitude
    ]

instance FromJSON BCoordsMax where
  parseJSON (Object bl) =
    BCoordsMax <$> bl .: "latitude"
            <*> bl .: "longitude"

instance ToJSON BoardBound where
  toJSON BoardBound {..} = object
    [
        "map" .= bmap
      , "time" .= btime
      , "bounding-box" .= boundingBox
    ]

instance FromJSON BoardBound where
  parseJSON (Object bb) =
    BoardBound <$> bb .: "map"
               <*> bb .: "time"
               <*> bb .: "bounding-box"
  parseJSON _ = mzero

instance ToJSON Item where
  toJSON Item {..} = object
    [
       "id" .= id
     , "latitude"  .= latitude
     , "longitude" .= longitude
    ]

instance ToJSON Map where
  toJSON Map {..} = object
   [
      "spheres" .= spheres
   ]

instance FromJSON Item where
  parseJSON (Object i) =
    Item  <$> i .:  "id"
          <*> i .:  "latitude"
          <*> i .:  "longitude"
  parseJSON _ = mzero

instance FromJSON Map where
  parseJSON (Object m) =
    Map <$> m .: "spheres"
  parseJSON _ = mzero

-- automatically created by aeson
instance ToJSON Board where
    toEncoding = genericToEncoding defaultOptions
instance FromJSON Board

instance ToJSON Time where
    toEncoding = genericToEncoding defaultOptions
instance FromJSON Time
