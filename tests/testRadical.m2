
--/run/media/jakob/TOEXT4/work/home_fc18/Projects/M2-master/M2/BUILD/master/M2

uninstallPackage "RandomIdeals"
installPackage "RandomIdeals"
-- check "RandomIdeals"


randomOpts := ()->
{
    opts = new OptionTable from {
     --"numVars"  => random(1,7),
     "absCoeff" => random(1,150),
     "maxDegree"=> random(1,10),
     "maxTerms" => random(1,4), 
     "maxGens"  => random(1,4)
    };
    return (opts);
}

nextPrime := (num)->
(
    while not isPrime(num) do
    {
        num=num+1;
    };
    return num;
)

randomIdealGen := (numVars, maxChar, opts)->
{
    x := symbol x;
    overPrimeField := ( 1==random(0,1));
    rng := null;
    if overPrimeField then 
    (
        p :=  random(2,maxChar);
        p = nextPrime(p);
        rng = ZZ/p[x_1..x_numVars];
    ) else
    (
        rng = QQ[x_1..x_numVars];
    );
    randomIdeal := defaultRandomIdealFactory(rng, opts);
    return randomIdeal;
}


run := ()->
{
    while (true) do
    {
        genI =  randomIdealGen( random(1,7), 200, randomOpts() );
        for i in 1..3000 do
        (
          --print "generating";
          I = genI();
          --print "generated !!";
          rI = radical I;
          try 
          (
              assert( isSubset(I, rI));
              rrI = radical rI;
              assert(rrI == rI );
          )
          then ()
          else
          (
              print "BUG";
              print toString (ring I);
              print toString (I);
              print i;
          );

        );
    }
}


run();

TEST ///
 randomOpts();
///


TEST ///
 needsPackage "RandomIdeals"
 randomQQIdealGen( random(1,7), randomOpts() );
///

end


