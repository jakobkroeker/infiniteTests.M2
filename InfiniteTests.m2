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

-- Idea for stopping condition: support not all stopping conditions (otherwise the user needs to write his own test driver)
-- Collect statistics: number of examples run, number of failed examples, (timing ?)
--
-- stopping condition takes as input a statistic parameter and returns true or false.

--randomCoefficientFactory (Ring) := Function =>(rng)->
--(
--     randomCoefficient := ()->
--     (
--	  return random(rng);
--     ); 
--)
--  checkStopCondition takes as parameter a  statistics object
-- and statistics contains info about numtrials and numFailedExamples



--genericTestDriver (Function, Function, Function, Function) := Function => (inputG, testee, resultCheck, failedExampleHandler, checkStopCondition)


--
end


