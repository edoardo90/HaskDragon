{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
module Main where

import           Yesod

--routes:
import Info.InfoContent
import Map.Handler

--persistence
import qualified Persistence.Red as Red
import qualified Tool.StrTools as Str

data App = App { getSiteInfo :: SiteInfo, getGameMap :: GameMap }

-- data HelloWorld = HelloWorld

mkYesod "App" [parseRoutes|
/ HomeR GET
/page1 Page1R GET
/page2 Page2R GET
/info SiteInfoR SiteInfo getSiteInfo
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

getPage2R :: HandlerT App IO Value
getPage2R = do
              idValueMaybe <- lookupGetParam "id"
              c <- lift $ Red.getValues "foo" "bar"
              return $ object ["msg" .= Str.coupleToString c,
                               "also" .= Str.maybeToStr idValueMaybe ]



main :: IO ()
main = warp 3000 $ App SiteInfo GameMap
