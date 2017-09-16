{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE DeriveGeneric #-}
module Application (main, App) where

import System.Process

import           Yesod
import Network.HTTP.Types (status201, status204)

--routes:
import Handlers.Info.InfoContent
import Handlers.Map.MapHandler
import Handlers.Player.PlayerHandler

--persistence
import qualified Persistence.Red as Red
import qualified Tool.StrTools as Str

--json
import Data.Aeson
import GHC.Generics

--Model
import Model.PlayerInfo
--tools
import Data.Text


data App = App { getSiteInfo :: SiteInfo, getGameMap :: GameMap, getGamePlayer :: GamePlayer }

mkYesod "App" [parseRoutes|
/       HomeR GET
/host   HostR GET
/info   SiteInfoR      SiteInfo    getSiteInfo
/map    GameMapR       GameMap     getGameMap
/player GamePlayerR    GamePlayer  getGamePlayer
|]

instance Yesod App

getHomeR :: Handler Html
getHomeR =  defaultLayout
  [whamlet|
      Hello - - - |  **  |  **  | - - -
  |]

getHostR :: Handler Value
getHostR = do
  hostname' <- liftIO hostname
  return $ object ["msg" .= hostname']

hostname :: IO String
hostname = readProcess "hostname" [] ""

main :: IO ()
main = warp 3000 $ App SiteInfo GameMap GamePlayer
