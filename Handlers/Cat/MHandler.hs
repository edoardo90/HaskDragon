{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE DeriveGeneric #-}

module Handlers.Cat.MHandler
 (
    module Handlers.Cat.MHandler
  , module Handlers.Cat.Route
 ) where

import Yesod
import Data.Aeson
import GHC.Generics

--subsites
import Handlers.Cat.Route
-- tools
import Data.Maybe (fromMaybe, isJust, isNothing, fromJust)
import qualified Data.ByteString.Lazy.Char8 as L
import           Data.Text                  (Text)
import  Data.Text.Lazy.Encoding as DLE


--persistence
import qualified Persistence.Red as Red
import qualified Tool.StrTools as Str

data Person = Person
  {
      name :: String
    , age ::  Int
  } deriving (Generic, Show)

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
instance ToJSON Person where
    toEncoding = genericToEncoding defaultOptions
instance FromJSON Person

instance ToJSON Cat where
  toJSON Cat {..} = object
      [  "nick" .= nick
       , "weight" .= weight
      ]

instance FromJSON Cat where
  parseJSON = withObject "Cat" $ \c -> Cat
          <$> c .: "nick"
          <*> c .: "weight"


instance ToJSON CatPerson where
    toJSON CatPerson {..} = object
        [ "name" .= personName
        , "age"  .= personAge
        , "cat"  .= cat
        ]
instance FromJSON CatPerson where
    parseJSON = withObject "CatPerson" $ \cp -> CatPerson
        <$> cp .: "personName"
        <*> cp .: "personAge"
        <*> cp .: "cat"

myCat = Cat "Rufy" 23
john = CatPerson "John" 20 myCat

gino = Person "gino" 10

-- / GameCatHomeR GET in Route

getGameCatHomeR :: Yesod master => HandlerT GameCat (HandlerT master IO) Value
getGameCatHomeR =   lift $
                          do
                          idValueMaybe <- lookupGetParam "game"
                          if isNothing idValueMaybe
                             then
                                return $ object ["msg" .= ("please provide game parameter"::String)]
                             else
                                return $ object ["msg" .=  ("ciaone" :: String)]

getPersonR :: Yesod master => HandlerT GameCat (HandlerT master IO) Value
getPersonR = lift getPersonR'

getPersonR' :: HandlerT master IO Value
getPersonR' = return $ object ["bischero" .= ("tu sei bischero" :: String)]

postPersonR :: Yesod master => HandlerT GameCat (HandlerT master IO) Html
postPersonR =  lift postPersonR'

postPersonR' :: Yesod master => HandlerT master IO Html
postPersonR' = do p <- requireJsonBody :: HandlerT master IO Person
                  defaultLayout [whamlet|Nice - post|]

postCatR :: Yesod master => HandlerT GameCat (HandlerT master IO) Html
postCatR =  lift $
                do p <- requireJsonBody :: HandlerT master IO Cat
                   defaultLayout [whamlet|Nice - cat post|]

postCatPersonR :: Yesod master => HandlerT GameCat (HandlerT master IO) Html
postCatPersonR =  lift $
                     do p <- requireJsonBody :: HandlerT master IO CatPerson
                        defaultLayout [whamlet|Nice - cat Person - post|]

printP :: IO ()
printP = L.putStrLn $ encode john

pgin :: L.ByteString
pgin = encode gino

f = decode "{\"name\":\"Joe\",\"age\":12}" :: Maybe Person


instance Yesod master => YesodSubDispatch GameCat (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGameCat)
