{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE ViewPatterns      #-}

module Handlers.Player.PlayerHandler
 (
    module Handlers.Player.PlayerHandler
  , module Handlers.Player.PlayerRoute
 ) where

import Yesod
import Network.HTTP.Types (status201, status204, status409)

--subsites
import Handlers.Player.PlayerRoute
--Model
import Model.GameMap (Map, Board, boardToBBound)
import Model.PlayerInfo (Player, newPlayer)

-- tools
import Data.Maybe (fromMaybe, fromJust, isJust, isNothing)
import qualified Data.ByteString.Lazy.Char8  as L8
import qualified Data.ByteString as BS
import Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Persistence.Red  as Red
import Tool.StrTools (textBase64)

postGamePlayerHomeR' :: Yesod master => PlayerName -> HandlerT GamePlayer (HandlerT master IO) Value
postGamePlayerHomeR' playerName = lift $
  do
    teamHeader <- lookupHeader "team"
    if isNothing teamHeader then
      return $ object ["msg" .= ("Please provide team in header" :: String)]
    else
      createAndSavePlayer (fromJust teamHeader) playerName

postGamePlayerHomeR :: Yesod master => PlayerName -> HandlerT GamePlayer (HandlerT master IO) Value
postGamePlayerHomeR playerName = readHeaderAndDo ( `createAndSavePlayer` playerName)

createAndSavePlayer :: Yesod master => BS.ByteString -> PlayerName ->  (HandlerT master IO) Value
createAndSavePlayer teamHeader playerName =
  do
    let player' = newPlayer (T.unpack playerName)
    savedPlayer <- lift $ Red.saveJsonPlayer teamHeader (TE.encodeUtf8 playerName) player'
    if isJust savedPlayer then
      sendResponseStatus status201  $ toJSON player'
    else do
      let playerStr = T.unpack playerName
      sendResponseStatus status409  $ object ["err" .= ("player " ++  playerStr ++  " is already present " :: String)]


postGamePlayerCollectR :: Yesod master => PlayerName -> SphereId -> HandlerT GamePlayer (HandlerT master IO) Value
postGamePlayerCollectR playerName sphereId = lift $
  do
    --p <- Red.getPlayerById
    return $ object ["msg" .= (" ciccio " :: String)]
--
-- /:playerName/collect/:sphereId
--
--   var game = persistence.getCurrentMap();
--   var missingSpheres = mapIds.length - Object.keys(playerSpheres.spheres).length;
--
--  {
--     spheres: {
--        sph01: 2017-08-01
--     },
--     missingSpheres : 6
--     status : " 5 to go"
--  }


readHeaderAndDo :: (MonadHandler m, MonadTrans t) => (BS.ByteString -> m Value) -> t m Value
readHeaderAndDo f = lift $
  do
    teamHeader <- lookupHeader "team"
    if isNothing teamHeader then
      return $ object ["msg" .= ("Please provide team in header" :: String)]
    else
      f (fromJust teamHeader)

instance Yesod master => YesodSubDispatch GamePlayer (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGamePlayer)
