## Subsites
Subsites, to me, are a bit more complicated then they shoud

In Main.hs we speicify the sub-routes in App data type

```haskell
data App = App { getSiteInfo :: SiteInfo, getGameMap :: GameMap }
```

they will be listed in #parseRoutes

```haskell
/info SiteInfoR SiteInfo getSiteInfo
/map  GameMapR  GameMap  getGameMap
```

for each subroute 2 files have to be created, one for speicify the possible paths, one for speicify
what to do in each path,
eg. in InfoRoute are listed:

```haskell
data SiteInfo = SiteInfo     --name of the subSite

mkYesodSubData "SiteInfo" [parseRoutes|
/ SiteInfoHomeR GET           
|]  -- name of the  Resource deined in the subSite 
```
