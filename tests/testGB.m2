
--/run/media/jakob/TOEXT4/work/home_fc18/Projects/M2-master/M2/BUILD/master/M2

uninstallPackage "RandomIdeals"
installPackage "RandomIdeals"
check "RandomIdeals"


randomOpts := ()->
{
    opts = new OptionTable from {
     --"numVars"  => random(1,7),
     "absCoeff" => random(1,15),
     "maxDegree"=> random(1,3),
     "maxTerms" => random(1,4), 
     "maxGens"  => random(1,4)
    };
    return (opts);
}



randomZZIdealGen:=(numVars, opts)->
{
    x := symbol x;
    rng := ZZ[x_1..x_numVars];
    randomIdeal = defaultRandomIdealFactory(rng,opts);
    return randomIdeal;
}



leadingTermsEquivalent := (I,J)->
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


run := ()->
{
    while (true) do
    {
        genI =  randomZZIdealGen( random(1,3), randomOpts() );
        for i in 1..3000 do
        (
          I = genI();
          print toString (I);
          print i;
          gI = ideal gens gb I;
          assert( ( (gens I)%gI) == 0 );
          ggI = ideal gens gb gI;
          assert(numColumns (gens gI) == numColumns(gens ggI));
          -- assert( gens ggI == gens gI ) ;
           assert( leadingTermsEquivalent( gI, ggI ) ) ;
        );
    }
}


TEST ///
 randomOpts();
///


TEST ///
 needsPackage "RandomIdeals"
 randomZZIdealGen( random(1,7), randomOpts() );
///


end


 absCoeff = random(1, opts#"absCoeff");
    numVars = random(1,15);
    maxMonomialDegree = random(1,7);
    maxTerms = random(1,5);
    maxGens = random(1,5);

    rng = ZZ[x_1..x_numVars]
    randomCoefficient = randomCoefficientFactory(coefficientRing rng ,absCoeff);
    randomMonomial = randomMonomialFactory(rng, maxMonomialDegree)
    randomTerm = randomTermFactory(randomCoefficient, randomMonomial)
    randomPoly = randomPolyFactory(randomTerm, maxTerms);
    randomIdeal = randomIdealFactory(randomPoly, maxGens);


