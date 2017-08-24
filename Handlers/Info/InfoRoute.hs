{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}

module Handlers.Info.InfoRoute where

import Yesod

data SiteInfo = SiteInfo

mkYesodSubData "SiteInfo" [parseRoutes|
/ SiteInfoHomeR GET
|]
