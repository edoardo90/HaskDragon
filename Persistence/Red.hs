{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeFamilies          #-}

module Persistence.Red (getValues, getValue, getGameMapById, saveJsonWithId) where
import qualified Database.Redis as DB
import Control.Monad.Trans
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as LBS

import Data.Aeson

main :: IO ()
main = print "hello"

type ID = BS.ByteString

getValues :: BS.ByteString -> BS.ByteString -> IO (Maybe (BS.ByteString, BS.ByteString))
getValues k1 k2 = do
    conn <- DB.connect DB.defaultConnectInfo
    DB.runRedis conn $ do
        DB.set "foo" "123"
        DB.set "bar" "456"
        foo <- DB.get k1
        bar <- DB.get k2
        liftIO $ return $ toMaybeCouple $ coupleF eitherToMaybe (foo, bar)

getValue :: BS.ByteString -> IO (Maybe BS.ByteString)
getValue k = do
  conn <- DB.connect DB.defaultConnectInfo
  DB.runRedis conn $ do
    value <- DB.get k
    liftIO $ return (eitherToMaybe value)


getGameMapById :: BS.ByteString -> IO (Maybe BS.ByteString)
getGameMapById k = do
  conn <- DB.connect DB.defaultConnectInfo
  DB.runRedis conn $ do
    value <- DB.hget "games" k
    liftIO $ return (eitherToMaybe value)


saveJsonWithId :: ToJSON a => BS.ByteString -> a -> IO ()
saveJsonWithId id obj = do
  conn <- DB.connect DB.defaultConnectInfo
  DB.runRedis conn $ do
   let str = lazyToStrictBS $ encode obj
   DB.hset "games" id str
   return ()

lazyToStrictBS :: LBS.ByteString -> BS.ByteString
lazyToStrictBS x = BS.concat $ LBS.toChunks x


eitherToMaybe :: Either a (Maybe b) -> Maybe b
eitherToMaybe (Right (Just x)) = Just x
eitherToMaybe _ = Nothing

coupleF :: (a -> b) -> (a,a) -> (b,b)
coupleF f (a, a') = (f a, f a')

toMaybeCouple :: (Maybe BS.ByteString, Maybe BS.ByteString) -> Maybe (BS.ByteString, BS.ByteString)
toMaybeCouple (Just bs1, Just bs2) = Just (bs1, bs2)
toMaybeCouple _ = Nothing
