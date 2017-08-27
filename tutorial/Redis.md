Create src/Persistence/Red.hs

### Dev op part

Edit cabal file

```yaml
[...]
library
  hs-source-dirs:      src
  exposed-modules:     Lib
                      ,Persistence.Red

  build-depends:       base >= 4.7 && < 5
                      , mtl
                      , hedis
                      , bytestring
[...]                      
```

Install redis on your environment and run redis-server inside a terminal instance
(to handle different terminal sessions you can use Terminator on linux systems, I use iTerm on Mac)
```bash
 $ redis-server
```

### Code part

Hedis provide a 1:1 API from haskell to redis.
Its functions, normally, return data "wrapped" inside IO Monad,
in order to use them inside handlers we exploit `lift` function, we
leverage on MonadTransformers, namely HandlerT

```haskell  
  gmap' <- lift (Red.getMapJsonById team)
```
