

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

emptyLogFkt = (str) ->
(
   ddf
)


-- issue : we do too much computations (if gi already fails, we should not compute ggI
-- so how to do that best?

boxedGB = (I)->
(
   result      := new MutableHashTable;
   result#"I"    = I;
   result#"gI"   = ideal gens gb I;
   
   assert( ( (gens I) % result#"gI") == 0 );
   result#"ggI"  = ideal gens gb result#"gI";
   return result;
)


GBReduceCheckFails = (input, result) ->
(
    return   ( (gens input) % result#"gI") != 0 ;
)


recordGBExample = (testSetup, input, result)->
(
                lf := openOut logfile;
                lf << "loadPackage(\"" | testSetup#"requiredPackage" |"\");" << endl;
                lf << "load(\"" | testSetup#"requiredFile" |"\");" << endl;
                lf << "R = " | (toExternalString ring input);
                lf << endl;
                lf << "input = " | (toString input);
                lf << endl;
                lf << "result = " << (toString testSetup#"resultCalculator") << "input";
                lf << "isInteresting =" | (toString testSetup#"isInteresting") << "(input, result)" ;
                lf << " if (isInteresting) then (  exit (123);        ); ";
                lf << "exit (0) ;";
)


 

--end


-- absCoeff = random(1, opts#"absCoeff");
--    numVars = random(1,15);
--    maxMonomialDegree = random(1,7);
--    maxTerms = random(1,5);
--    maxGens = random(1,5);

--    rng = ZZ[x_1..x_numVars]
--    randomCoefficient = randomCoefficientFactory(coefficientRing rng ,absCoeff);
--    randomMonomial = randomMonomialFactory(rng, maxMonomialDegree)
--    randomTerm = randomTermFactory(randomCoefficient, randomMonomial)
--    randomPoly = randomPolyFactory(randomTerm, maxTerms);
--    randomIdeal = randomIdealFactory(randomPoly, maxGens);


