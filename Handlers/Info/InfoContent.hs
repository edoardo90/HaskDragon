{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}

module Handlers.Info.InfoContent
 (
    module Handlers.Info.InfoContent
  , module Handlers.Info.InfoRoute
 ) where

import Handlers.Info.InfoRoute
import Yesod

getSiteInfoHomeR :: Yesod master => HandlerT SiteInfo (HandlerT master IO) Html
getSiteInfoHomeR  = lift $ defaultLayout [whamlet|Welcome to info page!|]

instance Yesod master => YesodSubDispatch SiteInfo (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesSiteInfo)
