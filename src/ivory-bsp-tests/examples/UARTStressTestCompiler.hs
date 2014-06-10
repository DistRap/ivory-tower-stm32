
import Ivory.Tower.Frontend

import qualified Ivory.HW.SearchDir as HW
import qualified Ivory.BSP.STM32.SearchDir as BSP

import BSP.Tests.Platforms
import UARTStressTest (app)

main :: IO ()
main = compilePlatforms conf (testPlatforms app)
  where
  conf = searchPathConf [HW.searchDir, BSP.searchDir]

