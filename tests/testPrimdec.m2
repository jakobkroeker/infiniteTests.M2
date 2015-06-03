--/run/media/jakob/TOEXT4/work/home_fc18/Projects/M2-master/M2/BUILD/master/M2

uninstallPackage "RandomIdeals"
installPackage "RandomIdeals"
check "RandomIdeals"

rng = QQ[x,y,z]
opts = new OptionTable from {
     "absCoeff" => 14,
     "maxDegree"=> 3,
     "maxTerms" => 4, 
     "maxGens"  => 3
};

 checkDecomposition = (I, decomp)->  (
       if (I==1) then ( assert(#decomp==0); return;);
       if (I==0) then (assert (#decomp==1 and I==decomp#0););
       assert(intersect(decomp)==I);
       apply(decomp,el->(isPrimary el));
  );

decompositionsEqual = (dA,dB)-> (
  if (not #dA==#dB) then return false;
  rdA := apply(dA, i->radical i);
  rdB := apply(dB, i->radical i);
  matchedPositions := new MutableHashTable ;
  for i in 0..#rdA-1 do
  for j in 0..#rdB-1 do  (
     if rdA#i==rdB#j then     (
         if matchedPositions#?j then return false;
         matchedPositions#j = 1;
     );
  );
  if not #matchedPositions==#rdA then return false;
  return true;
);

randomIdeal = defaultRandomIdealFactory(rng,opts)

for i in 1..100000 do
(
          I = randomIdeal(); 
          if  I==0 then continue;
          print (toString I);
          pd := primaryDecomposition I; 
          pEHV := primaryDecomposition ( I, Strategy=>EisenbudHunekeVasconcelos);
          pSY  :=  primaryDecomposition ( I, Strategy=>ShimoyamaYokoyama);
          checkDecomposition(I,pd);         
          checkDecomposition(I,pEHV);
          checkDecomposition(I,pSY); 
          assert(decompositionsEqual(pd,pEHV));
          assert(decompositionsEqual(pEHV,pSY));
 );

