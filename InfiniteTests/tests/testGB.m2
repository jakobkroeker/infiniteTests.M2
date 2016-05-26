
--/run/media/jakob/TOEXT4/work/home_fc18/Projects/M2-master/M2/BUILD/master/M2

--uninstallPackage "InfiniteTests"
--installPackage "InfiniteTests"
loadPackage "InfiniteTests"
--check "InfiniteTests"


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


runTests = ()->
{
    while (true) do
    {
        genI =  randomIdealGen( randomRingOpts(), randomIdealOpts() );
        for i in 1..10000 do
        (
         try(
              I = genI();
              -- print toString (I);
              print i;
              gI = ideal gens gb I;
              assert( ( (gens I)%gI) == 0 );
              ggI = ideal gens gb gI;
              assert(numColumns (gens gI) == numColumns(gens ggI));
              -- assert( gens ggI == gens gI ) ;
               assert( leadingTermsEquivalent( gI, ggI ) ) ;
          )
          else 
          (
                
                lf := openOut logfile;
                lf << "load(\"tests/testGB.m2\");" << endl;
                lf << "R = " | (toExternalString ring I);
                lf << endl;
                lf << "I = " | (toString I);
                lf << endl;
                lf << "  gI = ideal gens gb I;"<< endl;
                lf << "  assert( ( (gens I)%gI) == 0 );"<< endl;
                lf << " ggI = ideal gens gb gI;"<< endl;
                lf << " assert(numColumns (gens gI) == numColumns(gens ggI));"<< endl;
                lf << " -- assert( gens ggI == gens gI ) ;"<< endl;
                lf << " assert( leadingTermsEquivalent( gI, ggI ) ) ;"<< endl;
                lf << close;
                exit(123)
          );
        );
    }
}


TEST ///
 randomIdealOpts();
///


TEST ///
 needsPackage "InfiniteTests"
 randomZZIdealGen( random(1,7), randomIdealOpts() );
///


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


