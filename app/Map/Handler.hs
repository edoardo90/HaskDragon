{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}

module Map.Handler
 (
    module Map.Handler
  , module Map.Route
 ) where

import Yesod
import Map.Route
import Data.Maybe (fromMaybe)


--persistence
import qualified Persistence.Red as Red
import qualified Tool.StrTools as Str



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



instance Yesod master => YesodSubDispatch GameMap (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGameMap)
