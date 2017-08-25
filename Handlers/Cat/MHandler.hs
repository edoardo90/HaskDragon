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
import Handlers.Cap.Route
-- tools
import Data.Maybe (fromMaybe)
import qualified Data.ByteString.Lazy.Char8 as L
import           Data.Text                  (Text)


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

-- / GameMapHomeR GET in Route

getGameMapHomeR :: Yesod master => HandlerT GameMap (HandlerT master IO) Value
getGameMapHomeR =   lift $
                          do
                          idValueMaybe <- lookupGetParam "game"
                          let gameId = Str.maybeToStr idValueMaybe
                          if null gameId
                             then
                                return $ object ["msg" .= ("please provide game parameter"::String)]
                             else do
                                gameValue' <- lift $ Red.getGameMapById gameId
                                let gameValue = fromMaybe "" gameValue'  :: String
                                return $ object ["msg" .=  gameValue]

getPersonR :: Yesod master => HandlerT GameMap (HandlerT master IO) Value
getPersonR = lift getPersonR'

getPersonR' :: HandlerT master IO Value
getPersonR' = return $ object ["bischero" .= ("tu sei bischero" :: String)]

postPersonR :: Yesod master => HandlerT GameMap (HandlerT master IO) Html
postPersonR =  lift postPersonR'

postPersonR' :: Yesod master => HandlerT master IO Html
postPersonR' = do p <- requireJsonBody :: HandlerT master IO Person
                  defaultLayout [whamlet|Nice - post|]

postCatR :: Yesod master => HandlerT GameMap (HandlerT master IO) Html
postCatR =  lift $
                do p <- requireJsonBody :: HandlerT master IO Cat
                   defaultLayout [whamlet|Nice - cat post|]

postCatPersonR :: Yesod master => HandlerT GameMap (HandlerT master IO) Html
postCatPersonR =  lift $
                     do p <- requireJsonBody :: HandlerT master IO CatPerson
                        defaultLayout [whamlet|Nice - cat Person - post|]

-- lift $
--                 do post <- (requireJsonBody :: Handler Person)
--                    return $ object ["msg" .=  ("nice post" :: String)]

printP :: IO ()
printP = L.putStrLn $ encode john

pgin = L.putStrLn $ encode gino

f = decode "{\"name\":\"Joe\",\"age\":12}" :: Maybe Person


instance Yesod master => YesodSubDispatch GameMap (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGameMap)
