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
import Model.GameMap (Map(..), Board(..), boardToBBound)
import Model.PlayerInfo (Player(..), newPlayer)

-- tools
import Data.Maybe (fromMaybe, fromJust, isJust, isNothing)
import qualified Data.ByteString.Lazy.Char8  as L8
import qualified Data.ByteString as BS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Persistence.Red  as Red
import Tool.StrTools (textBase64)

postGamePlayerHomeR :: Yesod master => PlayerName -> HandlerT GamePlayer (HandlerT master IO) Value
postGamePlayerHomeR playerName = lift $ readTeamAnd ( `createAndSavePlayer` playerName )

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
postGamePlayerCollectR playerName sphereId = lift $ readTeamAnd (collectSphere' playerName)

collectSphere' ::  Yesod master => PlayerName -> BS.ByteString ->  (HandlerT master IO) Value
collectSphere' playerName team = do
  m <- lift $ Red.getMapJsonById team
  p <- getGamePlayer' playerName team
  if isNothing m then
    return $ object ["msg" .= (" no map found for specified team" :: String)]
  else
    if isNothing p then
      return $ object ["msg" .= ("no player with such name" :: String)]
    else do
      let (Board (Map gameSpheres) time) = fromJust m
      let (Player name playerSpheres) = fromJust p
      let toGo = length gameSpheres - length playerSpheres
      let msg = if toGo == 0 then "Good, you found all of them" else "Still " ++ show toGo ++ " to go!"
      return $ object ["status" .= msg,
                       "missingSpheres" .= toGo,
                       "spheres" .= playerSpheres]

getGamePlayer' ::  Yesod master => PlayerName -> BS.ByteString ->  (HandlerT master IO) (Maybe Player)
getGamePlayer' playerName team = lift $ Red.getPlayerById team (TE.encodeUtf8 playerName)


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

readTeamAnd :: MonadHandler m => (BS.ByteString -> m Value) -> m Value
readTeamAnd f =
  do
    teamHeader <- lookupHeader "team"
    if isNothing teamHeader then
      return $ object ["msg" .= ("Please provide team in header" :: String)]
    else
      f (fromJust teamHeader)

instance Yesod master => YesodSubDispatch GamePlayer (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGamePlayer)
