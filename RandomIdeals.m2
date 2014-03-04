newPackage(
     "RandomIdeals",
     Version => "0.1", 
     Date => "15.02.2013",
     Authors => {{
           Name => "Jakob Kroeker", 
           Email => "kroeker@uni-math.gwdg.de", 
           HomePage => "http://www.crcg.de/wiki/User:Kroeker"}
      },
     Configuration => {},
     PackageExports => {},
     Headline => "Framework to generate random ideals",
     DebuggingMode => true
)
--#     AuxiliaryFiles=>true

export {
  "randomCoefficientFactory",
  "randomMonomialFactory",
  "randomTermFactory",
  "randomPolyFactory",
  "randomIdealFactory",
  "defaultRandomIdealFactory"
}


--it is a little bit harder to write a random function
-- where the minVal and maxVal are in QQ, but possible.
restart

--randomCoefficientFactory returns a generator of values in [minVal, maxVal]
--
--tested for coeffRing = ZZ,QQ,RR. 
--accepts ZZ/p, but then minVal and maxVal has no meaning any more.
randomCoefficientFactory = method();
randomCoefficientFactory (Thing,ZZ,ZZ) := Function => (coeffRing, minVal,maxVal)->
(
  if coeffRing===CC then 
     error("for complex numbers please use the interface (CC, center_CC,radius_RR)");
  randomCoefficient := ()->
  (
     assert(minVal<=maxVal);
     if (minVal==maxVal) then return sub(minVal,coeffRing);
     result := random(minVal_ZZ,maxVal_ZZ);
     if result == 0 then return sub(result,coeffRing);
     if odd random(0,71) then return sub(result,coeffRing);
     sign := 1_coeffRing;
     --print ("result " |toString result);
     if (maxVal<0 or (odd random(0,100) and minVal<0 )) then sign = -1_coeffRing;
     --
     result = abs(result);
     while (true) do 
     (
	 nresult := random(coeffRing, Height=>result+1)*sign;
	 if instance(coeffRing,QuotientRing) then return nresult;
	 if (nresult >=minVal and nresult<= maxVal) then return nresult;
     );
     return random(coeffRing, Height=>result+1)*sign;
  );
  return randomCoefficient;
);

--randomCoefficientFactory returns a generator of values in [-absVal, absVal]
randomCoefficientFactory (Thing,ZZ) := Function => (coeffRing, absVal)->
(
     return randomCoefficientFactory(coeffRing,-abs(absVal),abs(absVal));
)


-- a randomCoefficientFactory version for complex numbers
-- returns a generator for random point in D(center,radius)
randomCoefficientFactory (Thing,CC,RR) := Function => (coeffRng, center,radius)->
(
     randomCoefficient := ()->
     (
         sign := 1_coeffRng;
         if ( odd random(0,100)) then sign = -1_coeffRng;
         result := center +  random(coeffRng, Height=>radius)*sign;
         return result;
     );
     return randomCoefficient;
);

-- a simple randomCoefficientFactory  version for other coefficient rings, e.g ZZ/p
-- utilizes random()
randomCoefficientFactory (Ring) := Function =>(rng)->
(
     randomCoefficient := ()->
     (
	  return random(rng);
     ); 
)

TEST ///
randomCoefficient= randomCoefficientFactory(ZZ,5)
randomCoefficient()
rcList := apply(1000, i->randomCoefficient() );

testRCmodP = method();

testRCmodP (Thing,ZZ,ZZ) := null => (rng, minVal,maxVal)->
(
  randomCoefficient := randomCoefficientFactory(rng,minVal,maxVal);
  rcList = apply(power(maxVal-minVal,3)+10, i->randomCoefficient() );
  apply(rcList, rc->(
	    assert(instance(rc,rng)); 
	    ) );
  --rcList
  if (minVal<=0 and maxVal>=0) then 
  assert ( 0 < #select(rcList, rc->(rc==0) ));
  assert ( 0 < #select(rcList, rc->(rc==minVal) )); 
  assert ( 0 < #select(rcList, rc->(rc==maxVal) ));
);

testRC = method();
testRC (Thing,ZZ,ZZ) := null => (rng, minVal,maxVal)->
(
  randomCoefficient := randomCoefficientFactory(rng,minVal,maxVal);
  rcList = apply(power(maxVal-minVal,3)+10, i->randomCoefficient() );
  apply(rcList, rc->(
	    assert(rc>=minVal and rc<=maxVal);
	    --assert(instance(rc,rng)); 
	    ) );
  --rcList
  if (minVal<0) then 
  assert ( 0 < #select(rcList, rc->(rc<0) ));
  if (maxVal>0) then 
  assert ( 0 < #select(rcList, rc->(rc>0) ));
  if (minVal<=0 and maxVal>=0) then 
  assert ( 0 < #select(rcList, rc->(rc==0) ));
  
  assert ( 0 < #select(rcList, rc->(rc==minVal) )); 
  assert ( 0 < #select(rcList, rc->(rc==maxVal) ));
);

testRCmodP(ZZ/7, -5 , 5); 
testRCmodP(ZZ/7, -7 , 5);

testRC(ZZ,5,5);
testRC(ZZ,-5,-5);
testRC(ZZ,-5,4);

testRC(QQ,5,5);
testRC(QQ,-5,-5);
testRC(QQ,-5,4);

testRC(RR,-5,4);
testRC(RR,-5,-5); 
testRC(RR,5,5); 

randomCoefficient= randomCoefficientFactory(CC,5_CC,1_RR)

try (
     --should fail!
randomCoefficient= randomCoefficientFactory(CC,5_ZZ,1_ZZ)
) then ((print "test failed");assert(false) ) else ();

randomCoefficient()


///

-- randomMonomialFactory-creates a generator for a random monomial in rng 
-- satisfying restriction on min and max degree.
-- 
-- currently no support for multidegree rings. 
randomMonomialFactory = method();
randomMonomialFactory ( Ring, ZZ, ZZ) := Thing => (rng, minDegree, maxDegree)->
(
     assert( maxDegree >= minDegree );
     randomMonomial := ()->
     (
       mon := 1_rng;
       g := gens rng;
       if (#g)>0 then
       (
	 monDegree := random(minDegree,  maxDegree);
         apply(monDegree, i->(mon= mon*(g#(random(#g)))));
       );
       return mon;     
    );
  return randomMonomial;
);

--randomMonomialFactory variant  defaults minDegree to 0
randomMonomialFactory (Ring, ZZ) := Thing =>(rng, maxDegree)->
(
      return randomMonomialFactory( rng,  0,maxDegree);
)

TEST ///
  rng = QQ[x,y,z]
  g = gens rng
  g#(random(#g))
  minDegreeSum := 3;
  maxDegreeSum := 3;
  
  testRandomMonomial = (rng,minDegreeSum,maxDegreeSum)->
  (
    randomMonomial = randomMonomialFactory(rng,minDegreeSum,maxDegreeSum);
    g:= gens rng;
    if #g>0 then 
    (
     rml :=  apply(100+power(maxDegreeSum-minDegreeSum,3),i->( 
	            rm := randomMonomial()) );
      apply(rml,i->(
		ds = sum(degree(i)); 
	        assert(ds <=maxDegreeSum and ds>=minDegreeSum );
		)
	   );  
      assert(0 < #select ( rml, rm -> (sum(degree(rm))==minDegreeSum)));
      assert(0 < #select ( rml, rm -> (sum(degree(rm))==maxDegreeSum)));
   );
  );
  testRandomMonomial(rng,3,3);
  testRandomMonomial(rng,0,3);
  
  rng = QQ
  g = gens rng
  --g#(random(#g))
  randomMonomial = randomMonomialFactory(rng,3)
  randomMonomial()
  testRandomMonomial(rng,1,3);
  
  rng = ZZ[x,y,z]
  g = gens rng
  g#(random(#g))
  randomMonomial = randomMonomialFactory(rng,3)
  randomMonomial()
  testRandomMonomial(rng,1,3);
   
///

--randomPolyFactory returns a generator for a random term in a polynomial
--parameters are generators for coefficient and the monomial.
randomTermFactory = method();
randomTermFactory (Function,Function) :=Thing => (randomCoefficientGen, randomMonomialGen)->
( 
   randomTerm := () ->
   (
	 return randomCoefficientGen()*randomMonomialGen(); 
   );
   return randomTerm;
      
);

TEST ///
 rng = QQ[x,y,z]
 randomCoefficient = randomCoefficientFactory(coefficientRing rng ,5);
 randomMonomial = randomMonomialFactory(rng,3)
 randomTerm = randomTermFactory(randomCoefficient, randomMonomial)
 apply(100, i->randomTerm());
///

randomPolyFactory = method();

--randomPolyFactory returns a generator for a random polynomial,
-- parameters are ge
randomPolyFactory(Function, ZZ) := Thing => (randomTermGen, maxTerms)->
(
    randomPoly := ()->
    (
	nTerms := random(1, maxTerms);
	rpoly :=  sum ( apply(nTerms, i-> randomTermGen() ) );
	return rpoly;
    );
    return randomPoly;
);

TEST ///
 rng = QQ[x,y,z]
 randomCoefficient = randomCoefficientFactory(coefficientRing rng ,5);
 randomMonomial = randomMonomialFactory(rng,3)
 randomTerm = randomTermFactory(randomCoefficient, randomMonomial)
  maxTerms = 3
  
  randomPoly := randomPolyFactory(randomTerm, maxTerms);
  rp = randomPoly()
  rpl = apply(1000, i->randomPoly() )
  lst = 0..maxTerms;
  mht = new MutableHashTable from new List from apply(lst, i->(i=>0))
 
  apply(#rpl-1, rpId-> (
    nc := numColumns (coefficients rpl#rpId)#0;
    --print nc;
    assert (nc <= maxTerms);
    mht#nc=(mht#nc)+1;
   ) );
  
   apply(keys mht, k ->assert(mht#k>0)); 
   peek mht 

///


randomIdealFactory = method();

--randomIdealFactory produces a generator for random ideals.
--parameters are a poly generator and the maximal number of equations.
randomIdealFactory (Function, ZZ) := Thing => (randomPolyGen, maxGens)->
(
     randomIdeal := ()->
     (
	  nGens := random(1, maxGens);
	  return ideal( apply(nGens, i->randomPolyGen()) );
     );
     return randomIdeal;
);


TEST ///
 rng = QQ[x,y,z]
 absCoeff = 5;
 randomCoefficient = randomCoefficientFactory(coefficientRing rng ,absCoeff);
 maxMonomialDegree = 3
 randomMonomial = randomMonomialFactory(rng, maxMonomialDegree)
 randomTerm = randomTermFactory(randomCoefficient, randomMonomial)
 maxTerms = 3
  
 randomPoly = randomPolyFactory(randomTerm, maxTerms);
 maxGens = 4
 randomIdeal = randomIdealFactory(randomPoly, maxGens);
 randomIdeal()

///

defaultRandomIdealFactory = method(Options=>{
	  "absCoeff"=>5,"maxDegree"=>3,"maxTerms"=>3, "maxGens"=>3});

defaultRandomIdealFactory (Ring) := Function => opts->(rng)->
(
 randomCoefficient := randomCoefficientFactory(coefficientRing rng ,opts#"absCoeff");
 randomMonomial := randomMonomialFactory(rng, opts#"maxDegree");
 randomTerm := randomTermFactory(randomCoefficient, randomMonomial); 
 randomPoly := randomPolyFactory(randomTerm, opts#"maxTerms");
 randomIdeal := randomIdealFactory(randomPoly, opts#"maxGens");
 return randomIdeal; 
);


--
end


