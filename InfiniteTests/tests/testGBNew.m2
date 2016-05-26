

export {
  "leadingTermsEquivalent",
  "createLogfileRecord",
  "GBReduceCheckFails",
  "boxedGB"
}

 
leadingTermsEquivalent = (I,J)->
(
    if (numColumns (gens I) != numColumns(gens J)) then return false;   
    for i in 0..(numColumns (gens I))-1 do
    (
        if not (leadTerm(I_i) % leadTerm(J_i) ==0 ) then
        (
            return false;
        );
        if not (leadTerm(J_i) % leadTerm(I_i) ==0 ) then
        (
            return false;
        );
    );   
    return (true);
);



-- issue : we do too much computations (if gi already fails, we should not compute ggI
-- so how to do that best?

boxedGB = (I)->
(
   result      := new MutableHashTable;
   result#"I"    = I;
   result#"gI"   = ideal gens gb I;
   
   -- assert( ( (gens I) % result#"gI") == 0 );
   -- if we do here an assert, we need a try catch in the test file
   result#"ggI"  = ideal gens gb result#"gI";
   return result;
);


GBReduceCheckFails = (inputValue, result) ->
(
    return   ( (gens inputValue) % result#"gI") != 0 ;
);



createLogfileRecord = (logfileName) ->
(
        tmpRecordGBExample := (testSetup, inputValue, result)->
        (
                lf := openOut logfileName;
                if (testSetup#"requiredPackage" =!= null) then
                (
                        lf << "loadPackage(\"" | testSetup#"requiredPackage" |"\");" << endl;
                );
                if (testSetup#"requiredFile" =!= null) then
                (
                        lf << "load(\"" | testSetup#"requiredFile" |"\");" << endl;
                );
                lf << "R = " | (toExternalString ring inputValue);
                lf << endl;
                lf << "inputValue = " | (toString inputValue);
                lf << endl;
                lf << "result =  testSetup#\"resultCalculator\" inputValue; " << endl;
                lf << "isInteresting =  testSetup#\"isInteresting\" (inputValue, result)" << endl ;
                lf << " if (isInteresting) then (  exit (123);        ); " << endl;
                lf << "exit (0) ;" << endl;
                lf << flush;
                lf << close;
                
        );
        return tmpRecordGBExample;
)
