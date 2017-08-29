{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeFamilies          #-}

module Persistence.Red (  saveJsonMap
                        , saveJsonPlayer
                        , getMapJsonById
                        , getPlayerById
                        ) where
import qualified Database.Redis as DB
import Control.Monad.Trans
import Data.Maybe (fromJust, fromMaybe, isNothing, isJust)
import Data.Either (isRight, isLeft)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 as BS8

import Data.Aeson
import Model.GameMap (Map, Board)
import Model.PlayerInfo (Player, newPlayer)

main :: IO ()
main = print "hello"

type ID = BS.ByteString

getMapJsonById :: BS.ByteString -> IO (Maybe Board)
getMapJsonById id = connectRedisAnd (getMapJsonById' id)

getMapJsonById' id conn =
 DB.runRedis conn $ do
   map' <- DB.hget "games" id
   let map'' = LBS.fromStrict <$>  eitherToMaybe map'
   let map = fromMaybe "" map''
   let maybeJson = decode map :: Maybe Board
   return maybeJson

getPlayerById :: ID -> ID -> IO (Maybe Player)
getPlayerById team playerId = connectRedisAnd (getPlayerById' team playerId)

getPlayerById' team playerId conn =
  DB.runRedis conn $ do
   player' <- DB.hget (getPlayerTeam team) playerId
   let player'' = LBS.fromStrict <$>  eitherToMaybe player'
   let player = fromMaybe "" player''
   let maybeJson = decode player :: Maybe Player
   return maybeJson

saveJsonWithId :: ToJSON a => BS.ByteString -> BS.ByteString -> a -> IO (Maybe a)
saveJsonWithId hashId objectId obj = connectRedisAnd (saveJsonWithId' hashId objectId obj)

saveJsonWithId' hashId objectId obj conn =
    DB.runRedis conn $ do
      let encodedObj = lazyToStrictBS $ encode obj
      alreadyPresent <- DB.hget hashId objectId
      if isJust $ eitherToMaybe alreadyPresent then
        return Nothing
      else do
        DB.hset hashId objectId encodedObj
        return (Just obj)

saveJsonMap :: ToJSON a => BS.ByteString -> a -> IO (Maybe a)
saveJsonMap objectId object = saveJsonWithId "games" objectId object

saveJsonPlayer :: ToJSON a => BS.ByteString -> BS.ByteString -> a -> IO (Maybe a)
saveJsonPlayer team playerId player = saveJsonWithId (getPlayerTeam team) playerId player

connectRedisAnd :: (DB.Connection -> IO (Maybe a)) -> IO (Maybe a)
connectRedisAnd action = do
  conn <- DB.connect DB.defaultConnectInfo
  connAlive <- DB.runRedis conn DB.ping
  if isLeft connAlive then
    return Nothing
  else
    action conn

getPlayerTeam team = (BS.append "players-" team)

lazyToStrictBS :: LBS.ByteString -> BS.ByteString
lazyToStrictBS x = BS.concat $ LBS.toChunks x

eitherToMaybe :: Either a (Maybe b) -> Maybe b
eitherToMaybe (Right (Just x)) = Just x
eitherToMaybe _ = Nothing
