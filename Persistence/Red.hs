{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeFamilies          #-}

module Persistence.Red (getValues, getValue, getGameMapById) where
import qualified Database.Redis as DB
import Control.Monad.Trans
import Data.ByteString
import qualified Data.ByteString.Char8  as BS

main :: IO ()
main = print "hello"

getValues :: ByteString -> ByteString -> IO (Maybe (ByteString, ByteString))
getValues k1 k2 = do
    conn <- DB.connect DB.defaultConnectInfo
    DB.runRedis conn $ do
        DB.set "foo" "123"
        DB.set "bar" "456"
        foo <- DB.get k1
        bar <- DB.get k2
        liftIO $ return $ toMaybeCouple $ coupleF eitherToMaybe (foo, bar)


getValue :: String -> IO (Maybe String)
getValue k = do
  conn <- DB.connect DB.defaultConnectInfo
  DB.runRedis conn $ do
    value <- DB.get (BS.pack k)
    liftIO $ return  $  (BS.unpack <$> (eitherToMaybe value))


getGameMapById :: String -> IO (Maybe String)
getGameMapById k = do
  conn <- DB.connect DB.defaultConnectInfo
  DB.runRedis conn $ do
    value <- DB.hget "games" (BS.pack k)
    liftIO $ return (BS.unpack <$> (eitherToMaybe value))

eitherToMaybe :: Either a (Maybe b) -> Maybe b
eitherToMaybe (Right (Just x)) = Just x
eitherToMaybe _ = Nothing

coupleF :: (a -> b) -> (a,a) -> (b,b)
coupleF f (a, a') = (f a, f a')

toMaybeCouple :: (Maybe ByteString, Maybe ByteString) -> Maybe (ByteString, ByteString)
toMaybeCouple (Just bs1, Just bs2) = Just (bs1, bs2)
toMaybeCouple _ = Nothing
