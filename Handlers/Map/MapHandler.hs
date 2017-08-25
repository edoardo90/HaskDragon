{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE DeriveGeneric #-}

module Handlers.Map.MapHandler
 (
    module Handlers.Map.MapHandler
  , module Handlers.Map.MapRoute
 ) where

import Yesod
import Data.Aeson
import GHC.Generics

--subsites
import Handlers.Map.MapRoute
--Model
import Model.GameMap (Cat)
-- tools
import Data.Maybe (fromMaybe, fromJust, isJust)
import qualified Data.ByteString.Lazy.Char8  as L
import qualified Data.ByteString.Char8 as B8
import Data.Text as T
import qualified Persistence.Red  as Red
import Tool.StrTools (textBase64)

getGameMapHomeR :: Yesod master => HandlerT GameMap (HandlerT master IO) Value
getGameMapHomeR = lift $ return $ object ["bischero" .= ("MAP -> tu sei bischero" :: String)]

postGameMapHomeR :: Yesod master => HandlerT GameMap (HandlerT master IO) Value
postGameMapHomeR = lift $
                      do
                        hs <- lookupHeader "team"
                        if isJust hs then do
                          let team = fromJust hs
                          cat <- requireJsonBody :: HandlerT master IO Cat
                          _ <- lift (Red.saveJsonWithId team cat)
                          return $ object ["bischero" .= B8.unpack team,
                                           "cat:" .= cat
                                          ]
                        else
                          return $ object ["bischero" .= ("provide team header specifying your team" :: String)]

instance Yesod master => YesodSubDispatch GameMap (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGameMap)
