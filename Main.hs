module Main where

import           Control.Monad          (unless)
import           Control.Monad.IO.Class (liftIO)
import qualified Data.Binary.Get        as G
import qualified Data.ByteString.Lazy   as BSL
import           Data.Int               (Int16, Int32, Int64)
import           Data.List              (intercalate)
import           Data.Word              (Word16, Word32, Word64)
import           Debug.Trace            (trace)
import           System.Environment     (getArgs)
import           System.Exit            (exitFailure, exitSuccess)
import           System.IO              (hPutStrLn, stderr)

tr a = trace (show a) a

data Header = Header {
    len     :: Word16,
    period  :: Word32,
    npoints :: Word32
} deriving Show

type Row = (Double, Double)
    --deriving Show

getHeader :: G.Get Header
getHeader = do
    file_id <- G.getWord32be
    unless (file_id == 1380926976) (error "Bad header")
    unk1 <- G.getWord8
    unk2 <- G.getWord8
    len <- G.getWord16le
    zero <- G.getWord32be
    unless (zero == 0) (error "Bad header")
    unk4 <- G.getWord16le
    unk5 <- G.getWord16le
    period <- G.getWord32le
    npoints <- G.getWord32le
    npoints' <- G.getWord32le
    unless (npoints == npoints') (error "Bad header")
    return $! Header len period npoints

getRow :: G.Get Row
getRow = do
    v <- G.getWord32le
    a <- G.getWord32le
    return $ ((fromIntegral v :: Double) / 10000.0, (fromIntegral a :: Double) / 10000.0)

getRows :: G.Get [Row]
getRows = do
    empty <- G.isEmpty
    if empty
      then return []
      else do row <- getRow
              rows <- getRows
              return (row:rows)

getRof :: G.Get (Header, [Row])
getRof = do
    header <- getHeader
    rows <- getRows
    return (header, rows)

readRof :: BSL.ByteString -> IO ()
readRof bs = do
    let (hdr, rows) = G.runGet getRof bs
    let len = fromIntegral (3 * npoints hdr) :: Int
    unless (len == length rows) (error $ "Expecting " ++ show len ++ " rows, got " ++ show (length rows) ++ " instead")
    let period' = fromIntegral (period hdr) :: Double
    let dat = prepend [0, period'..] (map flatten $ trips rows)
    let dat' = map (\fs -> intercalate ", " $ map show fs) dat
    putStrLn "time, V1, I1, V2, I2, V3, I3"
    putStrLn $ intercalate "\n" dat'

prepend :: [a] -> [[a]] -> [[a]]
prepend [] _                = []
prepend _ []                = []
prepend (x:rest) (xs:rests) = [x:xs] ++ prepend rest rests

trips :: [a] -> [[a]]
trips []              = []
trips (a1:a2:a3:rest) = [a1,a2,a3] : trips rest

flatten [(a1,b1),(a2,b2),(a3,b3)]= [a1,b1,a2,b2,a3,b3]

main :: IO ()
main = do
    args <- getArgs
    unless (length args > 0) (hPutStrLn stderr "Usage:\nreadrod <rof file>" >> exitFailure)
    let filename:_ = args
    bs <- BSL.readFile filename
    readRof bs
