newPackage(
     "InfiniteTests",
     Version => "0.1", 
     Date => "22.05.2016",
     Authors => {{
           Name => "Jakob Kroeker", 
           Email => "kroeker@spaceship-earth.net", 
           HomePage => "http://www.crcg.de/wiki/User:Kroeker"}
           
      },
      AuxiliaryFiles=>true,
     Configuration => {},
     PackageExports => {},
     Headline => "Framework for random tests",
     DebuggingMode => true
)
--#     AuxiliaryFiles=>true


export {
  "dryRunDriver"
  }
  
export {
  "basicTestDriver",
  "basicSearchDriver",
  "createSearchEndCheckByNumTests",
  "createSearchEndCheckByFoundExamples",
  "createInfiniteSearchEndCheck",
  "createNotifyByNumTrial",
  "defaultLogfileIfNotSet",
  "defaultRunParameters",
  "runSearchScript",
  "randomCoefficientFactory",
  "randomMonomialFactory",
  "randomTermFactory",
  "randomPolyFactory",
  "randomIdealFactory",
  "randomIdealGen",
  "defaultRandomIdealFactory",
  "defaultIdealOpts",
  "defaultRingOpts",
  "emptyLogFkt"
}


emptyLogFkt = (str) ->
(
   
);


-- question: how to design the timeoutRerun option?
-- maybe the user wants to give the rerun time directly
-- but also maybe he wants to give a factor (rerun time is basicTimeout multiplied with the rerun factor)
-- so one option is to provide a helper function which  calculates the rerun factor from a rerun time?
-- another thing is timeoutRerunCycles (default should be 1):
-- if an example fails with a timeout, it is rerun for given number of cycles to be considered as a failed timeout
-- and in each rerun cycle the timeout is = basic timeout * (rerun factor powered to the current cycle number )
-- the first cycle number is zero.


-- rename fullinput to runnee ?

defaultRunParameters = ()->
(
--
  dp := new MutableHashTable;
  --
  dp#"M2binary" = "M2";
  --
  dp#"fullinput"="input/gbZ/testGB.config.00";
  --
  dp#"keepLog" = 0;
  --
  dp#"catchTimeoutExamples" = 0;
  --
  dp#"catchOutOfMem" = 0;
  --
  dp#"basicTimeout" = 10;
  --
  dp#"timeoutRerunFactor" = 10; -- only relevant if we want to catch timeout examples
  --
  dp#"virtualMemoryLimit" = 1000000; -- unfortunately it is hard to limit memory usage correctly, so this is a rough approach
  --
  dp#"maxFindings" = 1;
  --
  dp#"idx" = 1; -- do not run the same test in parallel with same idx
  --
  dp#"timeoutCommand" = "timeout"; -- better that this command is somehow installed by M2 if necessary (what to do on MAC OS)
  --
  -- ulimit -v wont work as parameter !!
  dp#"ulimitCommand" = "ulimit "; -- better that this command is somehow installed by M2 if necessary (what to do on MAC OS)
  --  
  --  
  return dp;
)

 

createSearchEndCheckByFoundExamples = (minExamples)->
(
  searchEndIsReached := (runStatistics) ->
  (
     return runStatistics#"foundExampleNumber" > minExamples ;
  );
  return searchEndIsReached;
)



createSearchEndCheckByNumTests = (maxTests)->
(
  searchEndIsReached := (runStatistics) ->
  (
     return runStatistics#"TestCount" > maxTests ;
  );
  return searchEndIsReached;
)


createInfiniteSearchEndCheck = () ->
(
  searchEndIsReached := (runStatistics) ->
  (
     return false ;
  ); 
  return searchEndIsReached;
)

defaultLogfileIfNotSet = method();


defaultLogfileIfNotSet (Thing, String) := (logfile, defaultValue1) ->
(
    if ( String =!= (class logfile) )  then 
    (
      -- logfile not set. 
      -- usually log filename is set from testing shell script
      -- so likely this code is not run from the testing shell script but probably directly from M2
      -- Setting it to something:
      logfile = defaultValue1 ;
    );
    return logfile;
) 
     
createNotifyByNumTrial = (modTestCount, modExampleCount) ->
(

   lastTestCount := 0;
   lastExampleCount := 0;
   
   notify := statistics ->
   (
      if (statistics#"testCount" != lastTestCount) then 
      (
        lastTestCount = statistics#"testCount";
        if (statistics#"testCount" % modTestCount == 0) then
        (
            << ( toString statistics#"testCount"  | " runs performed" ) << endl << flush;
            
        );
      );
      
      if (statistics#"exampleCount" != lastExampleCount) then 
      (
        lastExampleCount = statistics#"exampleCount";
        if (statistics#"exampleCount" % modExampleCount==0 ) then
        (
            << ( toString statistics#"exampleCount"  | " examples found !" )  << endl << flush;
        );
      );
      
   );
   return notify;
)
 

dryRunDriver = (testSetup) ->
(
    print "dry test run";
    testSetup#"log"( "dry run");
  
    testStatistics := new MutableHashTable;
    
    testStatistics#"testCount" = 0;
    testStatistics#"exampleCount" = 0;
    
    inputValue := null;
    result := null;
    
    testStatistics#"testCount" = testStatistics#"testCount" + 1;
    print testStatistics#"testCount";
  
    if (testSetup#"requiredPackage" =!= null) then 
    (
      testSetup#"log"( "loadPackage \"" | testSetup#"requiredPackage" | "\";");
    );
    
    if (testSetup#"requiredFile" =!= null) then 
    (
        testSetup#"log"( "load \"" | testSetup#"requiredFile" | "\";");
    );
    
    -- log random seed
    testSetup#"log"( "-- InputValue = testSetup#\"inputGenerator\"()");
    
    InputValue := testSetup#"inputGenerator"();
    
    -- todo : we need serialization
    testSetup#"log"(" -- InputValue = " | toExternalString InputValue);
    
    testSetup#"log"( " result = "  | toString testSetup#"resultCalculator" | "(InputValue);");
    
    result = testSetup#"resultCalculator"(InputValue);
    
    testSetup#"log"( toString testSetup#"isInteresting" | "(InputValue, result)");
    
    testSetup#"isInteresting"(InputValue, result);
    
    testSetup#"notify"(testStatistics);
    testStatistics#"testCount"   = 1000004234000;
    testStatistics#"exampleCount" = 42342343976;
    
    testSetup#"notify"(testStatistics);
    testStatistics#"testCount"   = 1000004234001;
    testStatistics#"exampleCount" = 42342343977;
    
    testSetup#"notify"(testStatistics);
        
    print "dry run succeeded";
)

basicTestDriver = (testSetup) ->
(
    print "basicTestDriver called";
    
    testStatistics := new MutableHashTable;
    
    testStatistics#"testCount" = 0;
    
    testStatistics#"exampleCount" = 0;
    
    InputValue := null;
    
    result := null;
    
    while (not testSetup#"endReached"(testStatistics) ) do
    (
       InputValue = null;
       
       result = null;
    
       testStatistics#"testCount" = testStatistics#"testCount" + 1;
       --print testStatistics#"testCount";
       
        if (testSetup#"requiredPackage" =!= null) then 
        (
             testSetup#"log"( "loadPackage \"" | testSetup#"requiredPackage" | "\";");
        );
        
        if (testSetup#"requiredFile" =!= null) then 
        (
                testSetup#"log"( "load \"" | testSetup#"requiredFile" | "\";");
        );
       
       -- log random seed
       testSetup#"log"( "-- InputValue = testSetup#\"inputGenerator\"()");
       
       InputValue = testSetup#"inputGenerator"();
       
       -- todo : we need serialization
       testSetup#"log"(" -- InputValue = " | toExternalString InputValue);
       
       
       try
       ( 
          testSetup#"log"( " result = "  | toString testSetup#"resultCalculator" | "(InputValue);");
          
          result = testSetup#"resultCalculator"(InputValue);
          
          testSetup#"log"( toString testSetup#"isInteresting" | "(InputValue, result)");
          
          assert( not testSetup#"isInteresting"(InputValue, result) );
       )
       else
       (
            testStatistics#"exampleCount" = testStatistics#"exampleCount" + 1;
            
           testSetup#"recordExample"(testSetup, InputValue, result);
       );
       testSetup#"notify"(testStatistics);
    );
)






basicSearchDriver = (testSetup) ->
(
    testStatistics := new MutableHashTable;
    testStatistics#"testCount":
    testStatistics#"exampleCount" = 0;
    InputValue := null;
    result := null;
    
    while (not testSetup#"endReached"(testStatistics) ) do
    (
       InputValue = null;
       result = null;
    
       testStatistics#"testCount" = testStatistics#"testCount" + 1;
       
        if (testSetup#"requiredPackage" =!= null) then 
        (
        testSetup#"log"( "loadPackage \"" | testSetup#"requiredPackage" | "\";");
        );
        
        if (testSetup#"requiredFile" =!= null) then 
        (
                testSetup#"log"( "load \"" | testSetup#"requiredFile" | "\";");
        );
       
       testSetup#"log"( "-- InputValue = testSetup#\"inputGenerator\" () ");
       InputValue = testSetup#"inputGenerator"();
       
       -- todo : we need serialization
       
       testSetup#"log"(" -- InputValue = " | toExternalString InputValue);
       
       try
       ( 
          testSetup#"log"( " result =  " | toString testSetup#"resultCalculator" | "(InputValue);");
          
          result = testSetup#"resultCalculator"(InputValue);
          
          testSetup#"log"( toString testSetup#"isInteresting" | "(InputValue, result)");
          
          if ( testSetup#"isInteresting"(InputValue, result) ) then
          (
              --collect interesting examples
              testSetup#"recordExample"(testSetup, InputValue, result);
          );
       )
       else
       (    
           
             --collect failed examples
       );
       testSetup#"notify"(testStatistics);
    )
)


runSearchScript = runParameters ->
(

  cmd := ". ./bin/infiniteTest.sh ";  -- [0]
  
  cmd = cmd |" "| runParameters#"M2binary"; -- [1]
  
  cmd = cmd |" "| runParameters#"fullinput";-- [2]
  
  cmd = cmd |" "| runParameters#"keepLog";-- [3]
  
  cmd = cmd |" "| runParameters#"catchTimeoutExamples";-- [4]
  
  cmd = cmd |" "| runParameters#"catchOutOfMem";-- [5]
  
  cmd = cmd |" "| runParameters#"basicTimeout";-- [6]
  
  cmd = cmd |" "| runParameters#"virtualMemoryLimitInMB"*1000;-- [7]
  
  cmd = cmd |" "| runParameters#"maxFindings";-- [8]
  
  cmd = cmd |" "| runParameters#"idx";-- [9]
  
  cmd = cmd |" "| runParameters#"timeoutCommand";-- [10]
  
  cmd = cmd |" "| runParameters#"ulimitCommand";-- [11]
  
  cmd = cmd |" "|  runParameters#"timeoutRerunFactor";-- [12]
  print ("cmd is : \n "  | cmd);
  run cmd;
  exit
)

 

load "InfiniteTests/RandomIdealFactory.m2";

 

load "InfiniteTests/tests/testGBNew.m2";

print "here100"

--end 

-- Idea for stopping condition: support not all stopping conditions (otherwise the user needs to write his own test driver)
-- Collect statistics: number of examples run, number of failed examples, (timing ?)
--
-- stopping condition takes as InputValue a statistic parameter and returns true or false.

--randomCoefficientFactory (Ring) := Function =>(rng)->
--(
--     randomCoefficient := ()->
--     (
--          return random(rng);
--     ); 
--)
--  checkStopCondition takes as parameter a  statistics object
-- and statistics contains info about numtrials and numFailedExamples



--genericTestDriver (Function, Function, Function, Function) := Function => (inputG, testee, resultCheck, failedExampleHandler, checkStopCondition)




