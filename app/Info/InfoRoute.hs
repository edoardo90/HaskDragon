{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
module Info.InfoRoute where

import Yesod

data SiteInfo = SiteInfo

mkYesodSubData "SiteInfo" [parseRoutes|
/ SiteInfoHomeR GET
|]
