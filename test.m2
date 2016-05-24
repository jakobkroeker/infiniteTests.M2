restart
defaultParameter:=()->(
par := new MutableHashTable;
par#"M2binary"="M2";
par#"fullinput"="input/gbZ/testGB.config.00";
par#"keepLog"="0";
par#"considerTimeout"="0";
par#"checkOutOfMem"="0";
par#"basicTimeout"="10";
par#"memLimit"="1000000";
par#"maxBugs"="1";
par#"idx"="1";
par#"timeoutCommand"="gtimeout";
par
)

par = defaultParameter();

par#"basicTimeout"=20


runScript:=par->(
cmd="./bin/infiniteTest.sh"|" "|par#"M2binary"|" "| par#"fullinput" |" "| par#"keepLog" |" "| par#"considerTimeout" |" "| par#"checkOutOfMem" |" "| par#"basicTimeout" |" "| par#"memLimit" |" "| par#"maxBugs" |" "|  par#"idx" |" "| par#"timeoutCommand";
run cmd
)

par=genPar()
par#"memLimit"="10000"
runScript(par)

cmd=buildCMD(genPar())
par
par#"M2binary"="M2"
par#"M2binary"
apply(#par,i->par_i)
values(par)
keys(par) 

--run "./bin/infiniteTest.sh M2 input/gbZ/testGB.config.00 0 0 0 200 1000000 3 2"

par
run cmd

