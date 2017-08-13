Create src/Persistence/Red.hs

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
