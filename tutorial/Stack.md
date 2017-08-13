## Setting up with Stack
First I created a Slack project following the Stack readme
[https://docs.haskellstack.org/en/stable/README/](https://docs.haskellstack.org/en/stable/README/)

```bash
$ stack new haskdragon
$ cd haskdragon
$ stack setup
```

Edit haskdragon.cabal to include yesod dependency

[Stack guide, addding dependencies](https://github.com/commercialhaskell/stack/blob/master/doc/GUIDE.md#adding-dependencies)


```
[...]
executable haskdragon-exe
  hs-source-dirs:      app
  main-is:             Main.hs
  ghc-options:         -threaded -rtsopts -with-rtsopts=-N
  build-depends:       base
                     , haskdragon
                     , yesod
  default-language:    Haskell2010
[...]
```

Edit app/Main.hs
to try Hello world in yesod

[https://www.yesodweb.com/book/basics](https://www.yesodweb.com/book/basics)

(note: I have adapted it with ```module Main where```)

```haskell
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
module Main where
import           Yesod

data HelloWorld = HelloWorld

mkYesod "HelloWorld" [parseRoutes|
/ HomeR GET
|]

instance Yesod HelloWorld

getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|Hello World!|]

main :: IO ()
main = warp 3000 HelloWorld
```

From haskdragon directory

```
$ stack build
$ stack haskdragon-exe
```
haskdragon-exe is the value of executable
in haskdragon.cabal file
```
executable haskdragon-exe
```

Head to localhost:3000 to see hello world.

### (almost) Hot reloading workaround

A form of hot reloading can be reached with ghci (repl for ghc)

```
$ stack ghci
 [Compiler noise]
 * Main Lib> main
 Application launched @(yesod-core-1 [ Noise ]
```

From localhost:3000 you can interact with the app.

Changes to code can be seen with a quite fast process:

```
  [Ctrl-C]
  * Main Lib>
  :re
  * Main Lib> main
```

In this way changes can be seen without the burden of a full build.
