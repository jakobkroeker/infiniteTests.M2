newPackage(
     "InfiniteTests",
     Version => "0.1", 
     Date => "22.05.2016",
     Authors => {{
           Name => "Jakob Kroeker", 
           Email => "kroeker@spaceship-earth.net", 
           HomePage => "http://www.crcg.de/wiki/User:Kroeker"},
           AuxiliaryFiles=>true
           
      },
     Configuration => {},
     PackageExports => {},
     Headline => "Framework for random tests",
     DebuggingMode => true
)
--#     AuxiliaryFiles=>true

export {
  "randomCoefficientFactory",
  "randomMonomialFactory",
  "randomTermFactory",
  "randomPolyFactory",
  "randomIdealFactory",
  "randomIdealGen",
  "defaultRandomIdealFactory"
}

load "InfiniteTests/RandomIdealFactory.m2"

--
end


