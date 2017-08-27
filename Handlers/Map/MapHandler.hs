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
import Model.GameMap (Map, Board, boardToBBound)
-- tools
import Data.Maybe (fromMaybe, fromJust, isJust, isNothing)
import qualified Data.ByteString.Lazy.Char8  as L
import qualified Data.ByteString as BS
import Data.Text as T
import qualified Persistence.Red  as Red
import Tool.StrTools (textBase64)

getGameMapHomeR :: Yesod master => HandlerT GameMap (HandlerT master IO) Value
getGameMapHomeR = lift $
                    do
                      hs <- lookupHeader "team"
                      if isJust hs then do
                        let team = fromJust hs
                        let team' = L.unpack $ L.fromStrict team
                        gmap' <- lift (Red.getMapJsonById team)
                        if isNothing gmap' then
                          return $ object ["msg" .= ("sorry, no map for team: " ++ team' :: String)]
                        else
                          return $ object ["map" .= fromJust gmap']
                      else
                        return $ object ["msg" .= ("please provide a valide team header" :: String)]

postGameMapHomeR :: Yesod master => HandlerT GameMap (HandlerT master IO) Value
postGameMapHomeR = lift $
                      do
                        hs <- lookupHeader "team"
                        if isJust hs then do
                          let team = fromJust hs
                          gMap <- requireJsonBody :: HandlerT master IO Board
                          let gMapBounded = boardToBBound gMap
                          _ <- lift ( Red.saveJsonMap team gMapBounded)
                          return $ object ["team" .=  (L.unpack $ L.fromStrict team :: String),
                                           "map-saved" .= gMapBounded
                                          ]
                        else
                          return $ object ["msg" .= ("provide team header specifying your team" :: String)]

instance Yesod master => YesodSubDispatch GameMap (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGameMap)
