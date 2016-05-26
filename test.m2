restart

--uninstallPackage "InfiniteTests"
--installPackage "InfiniteTests"
--restart
--loadPackage "InfiniteTests"

  runParameters = defaultRunParameters();
  
  
  runParameters#"M2binary" = "M2";
  runParameters#"fullinput"="input/gbZ/simpleTestGB.config.00";
  runParameters#"keepLog" = 0;
  runParameters#"catchTimeoutExamples" = 0;
  runParameters#"catchOutOfMem" = 0;
  runParameters#"basicTimeout" = 10;
  runParameters#"timeoutRerunFactor" = 10; -- only relevant if we want to catch timeout examples
  runParameters#"virtualMemoryLimit" = 1000000; 
  runParameters#"maxFindings" = 1;
  runParameters#"idx" = 1; -- do not run the same test in parallel with same idx
  runParameters#"timeoutCommand" = "timeout"; -- better that this command is somehow installed by M2 if necessary (what to do on MAC OS)
  


runSearchScript(par)


