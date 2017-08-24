module Tool.StrTools where

import qualified Data.ByteString.Char8  as BS
import Data.Text as T

coupleToString :: Maybe (BS.ByteString, BS.ByteString) -> String
coupleToString (Just (x,  y)) = BS.unpack x ++ BS.unpack y
coupleToString _ = "nope..."

mayBsToStr :: Maybe BS.ByteString -> String
mayBsToStr (Just bs) = BS.unpack bs
mayBsToStr Nothing = ""

maybeToStr :: Maybe T.Text -> String
maybeToStr Nothing = ""
maybeToStr (Just x) = T.unpack x
