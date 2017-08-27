## Subsites
Subsites, to me, are a bit more complicated then they should, but still, let's try to figure them out.
What I understood on the subject is mostly thanks to:
[Official guide to substtes](https://www.yesodweb.com/book/creating-a-subsite)


In Main.hs we speicify the sub-routes in App data type

```haskell
data App = App { getSiteInfo :: SiteInfo, getGameMap :: GameMap }
```

Trivial note (but potentially time-saving): the "get" in "getGameMap" is not related to the REST GET method,
it is just a prefix to state that via the getGameMap record accessor we retrieve a GameMap constructor

In #parseRoutes we use the accessors to construct the Routes

```haskell
/info SiteInfoR SiteInfo getSiteInfo
/map  GameMapR  GameMap  getGameMap
```

for each subroute 2 files have to be created, one to specify the possible (sub-)paths, one to specify
what to do in each path,

In InfoRoute are listed:

```haskell
data SiteInfo = SiteInfo     --name of the subSite

mkYesodSubData "SiteInfo" [parseRoutes|
/ SiteInfoHomeR GET           
|]  -- name of the  Resource defined in the subSite
```

In InfoContent

```haskell
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}

module Handlers.Info.InfoContent
 (
    module Handlers.Info.InfoContent    -- in this way we specify that when importing InfoContent
                                        -- also InfoRoute will be imported, this is needed because
                                        -- Application.hs needs SiteInfo constructor, the subsite "name"
  , module Handlers.Info.InfoRoute
 ) where

import Handlers.Info.InfoRoute     -- we import InfoRoute for the SiteInfo and to link route with behaviour
import Yesod

-- logic of subsite here, note the "lift" function
getSiteInfoHomeR :: Yesod master => HandlerT SiteInfo (HandlerT master IO) Html
getSiteInfoHomeR  = lift $ defaultLayout [whamlet|Welcome to info page!|]        


instance Yesod master => YesodSubDispatch SiteInfo (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesSiteInfo)  -- with some language extensions we are able to use
  -- a function derived by Yesod for us: resourcesSiteInfo, name is by convention, formed as:
  -- resources and subsite name ("SiteInfo")
```
