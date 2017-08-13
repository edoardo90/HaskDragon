{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Persistence.Red where
import qualified Database.Redis as DB
import Control.Monad.Trans

main :: IO ()
main = do
    conn <- DB.connect DB.defaultConnectInfo
    DB.runRedis conn $ do
        DB.set "foo" "123"
        DB.set "bar" "456"
        foo <- DB.get "foo"
        bar <- DB.get "bar"
        liftIO $ print (foo, bar)
