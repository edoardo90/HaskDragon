{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeFamilies          #-}

module Persistence.Red where
import qualified Database.Redis as DB
import Control.Monad.Trans

main :: IO ()
main = print "hello"

getValues k1 k2 = do
    conn <- DB.connect DB.defaultConnectInfo
    DB.runRedis conn $ do
        DB.set "foo" "123"
        DB.set "bar" "456"
        foo <- DB.get "foox"
        bar <- DB.get "bar"
        liftIO $ return $ coupleF eitherToMaybe (foo, bar)


eitherToMaybe :: Either a (Maybe b) -> Maybe b
eitherToMaybe (Right (Just x)) = Just x
eitherToMaybe _ = Nothing

coupleF :: (a -> b) -> (a,a) -> (b,b)
coupleF f (a, a') = (f a, f a')
