{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
module Main where
import           Yesod
import qualified Lib

import qualified Persistence.Red as Red


data HelloWorld = HelloWorld

mkYesod "HelloWorld" [parseRoutes|
/ HomeR GET
/page1 Page1R GET
/page2 Page2R GET
|]

instance Yesod HelloWorld

getHomeR :: Handler Html
getHomeR = defaultLayout[whamlet|<a href=@{Page1R}> Go to page 1 </a>|]

getPage1R :: Handler Html
getPage1R =  defaultLayout [whamlet|Hello -....- World!|]

getPage2R = return $ object ["msg" .= "Hello World"]

main :: IO ()
main = warp 3000 HelloWorld
