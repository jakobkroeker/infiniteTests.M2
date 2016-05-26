infiniteTests.M2
===============

The aim of this package is to provide a framework for random testing of algorithms implemented in Macaulay2.
That it detects bugs by throwing random input at a testee function.
The framework may also be used to search for examples with interesting properties.
The intention of implementing a framework is to remove the burden from the user of writing boilerplate code.


The package is currently under development and in alpha status (functionality not complete).



Possible applications:

-find a crash by throwing random input at a function
-find a bug by comparing results of two different algorithm implementations
-find a bug by checking result invariants
-automate re-checking (rerun the failing example with recent Macaulay and check if it still fails)


Design draft:
  the (repeated) random tests are done by  'test driver'
 
  the test driver should usually have following parameters:
     
     - random input generator function (with no parameters)
     - resultCalculator (takes the output of the random input generator from above)
     - result check function (which takes the input and the resultCalculator output as parameters)
     - processFailingExample() which takes everything from above and
          -  e.g. generates a rerunnable .m2 file from it 
          -  or adds the failing example into a list /into a database
     - stopping condition (run forever/timelimit /max tests/ or whatever
     


NEW EXAMPLE:

run

`M2    InfiniteTests/Examples/minimalRunExample.m2`

to understand how it works, look at 
 `InfiniteTests/Examples/minimalRunExample.m2`
and at
  `input/gbZ/simpleTestGB.config.00`
  
more detailed documentation will follow in short

Remaining goals:

search for in some way minimal failing examples


deprecated Quickstart:

1. create a M2 test routine called `runTests()` and a separate test config file with user defined test options used in the test routine 
( see `tests/testGB.m2` and `input/gbZ/testGB.config.00` for example)
The test routine should in case of a detected bug write to a logfile (filename is stored by external script in variable 'logfile' )
and exit Macaulay2.

The test config file should load the Macaulay2 file with the test routine

Now call `./bin/infiniteTest.sh`  with appropriate parameters:
```
$1 = M2 binary
$2 = test config file
$3 = keep log (0,1)
$4 = consider timeout(0,1)
$5 = check for out of mem(0,1)
$6 = timelimit (in seconds) for one test iteration
${7} = memory limit (in kbyte)
${8} = max num bugs
${9} = idx for the test; do not use same config file with same idx
```

The observed potential bugs will be stored in the 'log/$templateFileName/bugs/' subfolder and will have a file ending '.bug'

deprecated Example:
----------------------

#### tests/testGB.m2
```

loadPackage "InfiniteTests"

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
              -- print i;
              gI = ideal gens gb I;
              assert( ( (gens I)%gI) == 0 );
              ggI = ideal gens gb gI;
              assert(numColumns (gens gI) == numColumns(gens ggI));
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
```

####  input/gbZ/testGB.config.00
```
load("tests/testGB.m2")

randomIdealOpts = ()->
{
    opts := new OptionTable from {
     "absCoeff" => 23,
     "maxDegree"=> 3,
     "maxTerms" => 4,  
     "maxGens"  => 2
    };
    return (opts);
}


randomRingOpts = ()->
{
    opts := new OptionTable from {
     "coeffRng" => ZZ,
     "numVars"=>random(0,2),
     "orderings" => {GRevLex,GLex,Lex },
     "maxWeight"=>5,
     "useWeights"=>false
    };
    return (opts);
}
```
####  command line call 

`./bin/infiniteTest.sh M2 input/gbZ/testGB.config.00 0 0 0 200 1000000 3 2`

runs the GB tests with settings from `testGB.config.00` with a timeout of 200 sec, 2GB memlimit, looking for 3 bugs and using search idx=2



