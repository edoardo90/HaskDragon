{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE DeriveGeneric #-}
module Application (main, App) where

import           Yesod

--routes:
import Handlers.Info.InfoContent
import Handlers.Cat.MHandler
import Handlers.Map.MapHandler

--persistence
import qualified Persistence.Red as Red
import qualified Tool.StrTools as Str

--json
import Data.Aeson
import GHC.Generics

data App = App { getSiteInfo :: SiteInfo, getGameCat :: GameCat, getGameMap :: GameMap }

data PPerson = PPerson
  {
      name :: String
    , age ::  Int
  } deriving (Generic, Show)

instance ToJSON PPerson where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON PPerson


-- data HelloWorld = HelloWorld

mkYesod "App" [parseRoutes|
/ HomeR GET
/page1 Page1R GET POST
/page2 Page2R GET
/info SiteInfoR SiteInfo getSiteInfo
/cat  GameCatR  GameCat  getGameCat
/map  GameMapR  GameMap  getGameMap
|]

instance Yesod App

getHomeR :: Handler Html
getHomeR =  defaultLayout
  [whamlet|
      <a href=@{Page1R}> Go to page 1 </a>
  |]

getPage1R :: Handler Html
getPage1R =  defaultLayout [whamlet|Hello -....- World!|]

postPage1R :: Handler Html
postPage1R = do p <- requireJsonBody :: Handler PPerson
                defaultLayout [whamlet|Nice - post|]

getPage2R :: HandlerT App IO Value
getPage2R = do
              idValueMaybe <- lookupGetParam "id"
              c <- lift $ Red.getValues "foo" "bar"
              return $ object ["msg" .= Str.coupleToString c,
                               "also" .= Str.maybeToStr idValueMaybe ]



main :: IO ()
main = warp 3000 $ App SiteInfo GameCat GameMap
