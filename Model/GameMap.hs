{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE RecordWildCards   #-}

module Model.GameMap (Cat) where

import Yesod
import Data.Aeson

-- tools
import Data.Maybe (fromMaybe)
import qualified Data.ByteString.Lazy.Char8 as L
import           Data.Text                  (Text)

--persistence
import qualified Tool.StrTools as Str

data Cat = Cat
    {
      nick :: String
    , weight :: Int
    }

data CatPerson = CatPerson
    { personName :: Text
    , personAge  :: Int
    , cat  :: Cat
    }

-- automatically created by aeson
--instance ToJSON Person where
--    toEncoding = genericToEncoding defaultOptions
--instance FromJSON Person

instance ToJSON Cat where
  toJSON Cat {..} = object
      [  "nick" .= nick
       , "weight" .= weight
      ]

instance FromJSON Cat where
  parseJSON = withObject "Cat" $ \c -> Cat
          <$> c .: "nick"
          <*> c .: "weight"
