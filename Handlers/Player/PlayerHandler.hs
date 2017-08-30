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
import Network.HTTP.Types (status201, status204, status404, status409)

--subsites
import Handlers.Player.PlayerRoute
--Model
import Model.GameMap (Map(..), Board(..), Item(..), boardToBBound)
import Model.PlayerInfo (Player(..), newPlayer, addItemToPlayer)

-- tools
import Data.Maybe (fromMaybe, fromJust, isJust, isNothing)
import qualified Data.ByteString.Lazy.Char8  as L8
import qualified Data.ByteString.Char8  as BS8
import qualified Data.ByteString as BS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Persistence.Red  as Red
import Tool.StrTools (textBase64)

postGamePlayerHomeR :: Yesod master => PlayerName -> HandlerT GamePlayer (HandlerT master IO) Value
postGamePlayerHomeR playerName = lift $ readTeamAndJson ( `createAndSavePlayer` playerName )

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
postGamePlayerCollectR playerName sphereId = lift $ readTeamAndJson (collectSphere' sphereId playerName)

collectSphere' ::  Yesod master => SphereId -> PlayerName -> BS.ByteString  -> (HandlerT master IO) Value
collectSphere' sphereId playerName team = do
  m <- lift $ Red.getMapJsonById team
  p <- getGamePlayer' playerName team
  if isNothing m then
    return $ object ["msg" .= (" no map found for specified team" :: String)]
  else
    if isNothing p then
      return $ object ["msg" .= ("no player with such name" :: String)]
    else do

      let (Board (Map gameSpheres) time) = fromJust m
      let player@(Player name playerSpheres) = fromJust p
      let foundSpheres = filter (\s -> Model.GameMap.id s == sphereId) gameSpheres
      let playerWithNewSphere =  foldr addItemToPlayer player foundSpheres

      savedPlayer <- liftIO $ Red.updateJsonPlayer team (BS8.pack name) playerWithNewSphere

      if isNothing savedPlayer then return $ object ["msg" .= ("player was not correctly saved" :: String)] else do

        let toGo = length gameSpheres - (length . _spheres . fromJust)  savedPlayer
        let msg = if toGo == 0 then "Good, you found all of them" else "Still " ++ show toGo ++ " to go!"

        return $ object ["status" .= msg
                         , "missingSpheres" .= toGo
                         , "spheres" .=   _spheres (fromJust savedPlayer)
                         , "playerNow" .= fromMaybe (object ["msg:" .= ("hmm?" :: String)]) (toJSON <$> savedPlayer)
                         ]

getGamePlayerInfoR :: Yesod master => PlayerName -> HandlerT GamePlayer (HandlerT master IO) Value
getGamePlayerInfoR playerName = lift $ readTeamAndJson $
  \team ->  do
              p <- lift $ Red.getPlayerById team (TE.encodeUtf8 playerName)
              maybe (sendResponseStatus status404  messagePlayerNotFuond) (return $ return $ toJSON p) p

messagePlayerNotFuond = object ["msg" .= ("player not found" :: String)]

getGamePlayer' ::  Yesod master => PlayerName -> BS.ByteString ->  (HandlerT master IO) (Maybe Player)
getGamePlayer' playerName team = lift $ Red.getPlayerById team (TE.encodeUtf8 playerName)


readTeamOrFallback :: MonadHandler m => (BS.ByteString -> m Value) -> m Value -> m Value
readTeamOrFallback actionWithTeam fallBack = do
    teamHeader <- lookupHeader "team"
    maybe fallBack actionWithTeam teamHeader

readTeamAndJson :: MonadHandler m => (BS.ByteString -> m Value) -> m Value
readTeamAndJson actionWithTeam = readTeamOrFallback actionWithTeam (return $  object ["msg" .= ("Please provide team in header" :: String)])


instance Yesod master => YesodSubDispatch GamePlayer (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGamePlayer)
