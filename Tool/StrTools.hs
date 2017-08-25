module Tool.StrTools where

import qualified Data.ByteString.Char8  as BS8
import qualified Data.ByteString as BS
import Data.Text as T

import qualified Data.ByteString.Base64 as Base64
import qualified Data.Text.Encoding as TE


-- | Base64-encodes a ByteString as Text.
--
-- This cannot fail since Base64 is ASCII.
textBase64 :: BS.ByteString -> Text
textBase64 bs = case TE.decodeUtf8' (Base64.encode bs) of
  Left ex -> error $ "textBase64: BUG: base64 encoding cannot be encoded: " ++ show ex -- this cannot happen
  Right t -> t


coupleToString :: Maybe (BS.ByteString, BS.ByteString) -> String
coupleToString (Just (x,  y)) = BS8.unpack x ++ BS8.unpack y
coupleToString _ = "nope..."

mayBsToStr :: Maybe BS.ByteString -> String
mayBsToStr (Just bs) = BS8.unpack bs
mayBsToStr Nothing = ""

maybeToStr :: Maybe T.Text -> String
maybeToStr Nothing = ""
maybeToStr (Just x) = T.unpack x
