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
createAndSavePlayer teamHeader playerName = do
    let player' = newPlayer (T.unpack playerName)
    savedPlayer <- lift $ Red.saveJsonPlayer teamHeader (TE.encodeUtf8 playerName) player'
    responseForSavedPlayer savedPlayer playerName

responseForSavedPlayer (Just savedPlayer') _ =  sendResponseStatus status201  $ toJSON savedPlayer'
responseForSavedPlayer Nothing playerName =
   sendResponseStatus status409  $ object ["err" .= ("player " ++  T.unpack playerName ++  " is already present " :: String)]



postGamePlayerCollectR :: Yesod master => PlayerName -> SphereId -> HandlerT GamePlayer (HandlerT master IO) Value
postGamePlayerCollectR playerName sphereId = lift $ readTeamAndJson (collectSphere' sphereId playerName)

collectSphere' ::  Yesod master => SphereId -> PlayerName -> BS.ByteString  -> (HandlerT master IO) Value
collectSphere' sphereId playerName team = do
  map' <- lift $ Red.getMapJsonById team
  player' <- lift $ Red.getPlayerById team (TE.encodeUtf8 playerName)
  handleCollecting map' player' team sphereId

handleCollecting :: MonadIO m => Maybe Board -> Maybe Player -> BS.ByteString -> SphereId -> m Value
handleCollecting Nothing _ _ _ = return $ object ["msg" .= (" no map found for specified team" :: String)]
handleCollecting _ Nothing _ _ = return $ object ["msg" .= ("no player with such name" :: String)]
handleCollecting (Just map') (Just player') team sphereId  = do
    let (name, playerWithNewSphere, gameSpheres) = getNamePlayerSpheres map' player' sphereId
    savedPlayer <- liftIO $ Red.updateJsonPlayer team (BS8.pack name) playerWithNewSphere
    return $ msgForCollectedSphere savedPlayer gameSpheres


getNamePlayerSpheres :: Board -> Player -> Int -> (String, Player, [Item])
getNamePlayerSpheres map' player' sphereId =
  let (Board (Map gameSpheres) time) = map'
      player@(Player name playerSpheres) = player'
      foundSpheres = filter (\s -> Model.GameMap.id s == sphereId) gameSpheres
      playerWithNewSphere =  foldr addItemToPlayer player foundSpheres
  in  (name, playerWithNewSphere, gameSpheres)


msgForCollectedSphere :: Foldable t => Maybe Player -> t a -> Value
msgForCollectedSphere Nothing _ = object ["msg" .= ("player was not correctly saved" :: String)]
msgForCollectedSphere (Just player) gameSpheres =
  let toGo = length gameSpheres - (length . _spheres) player
      msg = if toGo == 0 then "Good, you found all of them" else "Still " ++ show toGo ++ " to go!"
  in
    object ["status" .= msg
                     , "missingSpheres" .= toGo
                     , "spheres" .=   _spheres player
                     , "playerNow" .= toJSON player
                     ]


getGamePlayerInfoR :: Yesod master => PlayerName -> HandlerT GamePlayer (HandlerT master IO) Value
getGamePlayerInfoR playerName = lift $ readTeamAndJson $
  \team ->  do
              p <- lift $ Red.getPlayerById team (TE.encodeUtf8 playerName)
              maybe (sendResponseStatus status404  messagePlayerNotFuond) (return $ return $ toJSON p) p

messagePlayerNotFuond = object ["msg" .= ("player not found" :: String)]


readTeamOrFallback :: MonadHandler m => (BS.ByteString -> m Value) -> m Value -> m Value
readTeamOrFallback actionWithTeam fallBack = do
    teamHeader <- lookupHeader "team"
    maybe fallBack actionWithTeam teamHeader

readTeamAndJson :: MonadHandler m => (BS.ByteString -> m Value) -> m Value
readTeamAndJson actionWithTeam = readTeamOrFallback actionWithTeam (return $  object ["msg" .= ("Please provide team in header" :: String)])


instance Yesod master => YesodSubDispatch GamePlayer (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesGamePlayer)
