restart

needsPackage "InfiniteTests"

  runParameters = defaultRunParameters();
  
  
  -- this one is important: 
   
  runParameters#"fullinput"= "input/gbZ/simpleTestGB.config.00";
  
  runParameters#"basicTimeout" = 20;
  
  runParameters#"virtualMemoryLimitInMB" = 1000; 
  
  runParameters#"maxFindings" = 101;
  
  runParameters#"timeoutCommand" = "timeout"; -- better that this command is somehow installed by M2 if necessary (what to do on MAC OS)


runSearchScript(runParameters)


