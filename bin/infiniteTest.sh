#!/bin/bash
# $1 = binary
# $2 = input file
# $3 = keep log
# $4 = consider timeout
# $5 = check for out of mem
# $6 = tmelimit
# ${7} = memory limit
# ${8} = max num bugs
# ${9} = idx 
# ${10} = timeout command name 
# ${11} = ulimit command name 
# ${12} timeout factor


# Considering timeout means that after a timeout the last example is ran again 
#and if the computation hits the extTimeout, then we have an example hitting a timeout.

export M2binary=$1

fullinput=$2
keepLog=$3    
considerTimeout=$4
checkOutOfMem=$5
basicTimeout=$6
killTimeout=$(($basicTimeout +30))

timeoutCommand=${10}

extTimeout=$((${11} * $basicTimeout))



#maxMinimizeTime=$((3600*${10}))

elapsedMinimizeTime=0


echo "binary:   "$M2binary
echo "testing   "$fullinput
echo "considerTimeout  "$considerTimeout
echo "checkOutOfMem    "$checkOutOfMem


#echo "keepLog:"$keepLog
if [ $keepLog -eq 1 ] ; then  echo "keep log " ; fi;
if [ $keepLog -eq 0 ] ; then  echo " do not keep log " ; fi;
echo "timeout:  "$basicTimeout" sec"
memlimit=${7}
echo "memlimit: "$memlimit" kb"
maxBugs=$((${8} + 0));
echo "maxBugs : "$maxBugs" "
export rnd=$RANDOM
idx=${9}
echo "idx : "$idx" "


ulimit -v $memlimit
export count=0;




filename="${fullinput##*/}"
echo $filename


if [ ! -e "$fullinput" ]
then
    fullinput="input/"$fullinput
fi;

if [ ! -e "$fullinput" ]
then
    echo "input file does not exist";
    exit;
fi;


echo $fullinput

set +H

mkdir -p /tmp/testM2/input/$filename/
mkdir -p log/$filename/bugs
if [ -e "log/$filename/bugs/id_$idx.count" ]
then
    . log/$filename/bugs/id_$idx.count
fi


export hid=`hostname |sed "s/[^0-9]//g"`

if [ -z "$hid" ]
then 
    hid="0";
fi;

echo "hid="$hid

export idx=$(($hid*100+${idx}));

echo "idx="$idx
echo "count="$count
echo "started with " >> log/$filename/id_$idx.log

read -p "Press [Enter] key to start testing with parameters as above"


echo $0" "$@  >> log/$filename/id_$idx.log

while [ $count -lt $maxBugs ] ; 
do 

    export randomNum=$(od -N 6 -t uL -An /dev/urandom | tr -d " ") 
    export randomNum=$( echo $randomNum" % 2^30" | bc ) # have to cut random num (on 32 bit machine only?)


    echo "randomNum: " $randomNum

    rm -f log/$filename/$filename.id_$idx.$count
    sleep 3
    echo "count: "$count;
    touch log/$filename/id_$idx.$count
    echo 'logfile = "log/'$filename'/id_'$idx'.'$count'";'  >/tmp/testM2/input/$filename/$filename.$idx.in; 

    cat $fullinput >> /tmp/testM2/input/$filename/$filename.$idx.in;

    cat /tmp/testM2/input/$filename/$filename.$idx.in;    

    echo " runTests() " >> /tmp/testM2/input/$filename/$filename.$idx.in;  

    # set -o pipefail : see https://bclary.com/blog/2006/07/20/pipefail-testing-pipeline-exit-codes/
    # timeout --kill-after 5 300 top 
    # 
    if [ $keepLog -eq 1 ] 
    then
        set -o pipefail; $timeoutCommand --kill-after=15 $basicTimeout  $M2binary   /tmp/testM2/input/$filename/$filename.$idx.in 2>&1 | tee -a log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    else
        set -o pipefail; $timeoutCommand --kill-after=15 $basicTimeout  $M2binary /tmp/testM2/input/$filename/$filename.$idx.in 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi;
    echo "normal run finished"
    #echo "show output file ******************************************" 
    #cat log/$filename/id_$idx.$count;
    #cat log/$filename/id_$idx.$count > /tmp/testM2/input/$filename/$filename.$idx.output;
    sync
    ##echo 3 > /proc/sys/vm/drop_caches
    #echo "show output file after sync+++++++++++++++++++++++++++++++++++"
    #cat log/$filename/id_$idx.$count;

    #sleep 15; # wait for disc sync...
    #echo "show output file after sleep ----------------------------------" 
    #cat log/$filename/id_$idx.$count;
    #sleep 20;  

    if [ $status -eq 253 ] || [ $status -eq 252 ]
    then
       overflow=1;
    else
       overflow=0;
    fi;

    if ( [ $status -eq 137 ] && [ $considerTimeout -eq 1 ] )  || ( [ $status -eq 124 ] && [ $considerTimeout -eq 1 ]  )
    then
        echo "quit;" >> log/$filename/id_$idx.$count;

        sleep 2;
        set -o pipefail; $timeoutCommand --kill-after=5 $extTimeout  $M2binary  log/$filename/id_$idx.$count 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi; 

    if  ( [ $status -eq 14 ] && [ $checkOutOfMem -eq 0 ] ) || ( [ $status -eq 137 ] && [ $considerTimeout -eq 0 ] )  || ( [ $status -eq 124 ] && [ $considerTimeout -eq 0 ] ) || [ $status -eq 0 ] || ( [ $overflow -eq 1 ] && [ $ignoreOverflow -eq 1 ] )
    then
        # export count=$(($count )); 
        echo "doNothing ";echo "doNothing ">> log/$filename/id_$idx.log;
    else 

        echo "raiseCount ";echo "raiseCount ">> log/$filename/id_$idx.log;
        echo "quit;" >> log/$filename/id_$idx.$count;

        if [ $status -eq 14 ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.outofmem.bug;
        fi;

        if [ $status -eq 137 ] || [ $status -eq 124 ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.timeout.bug;
        fi;

        if [ $overflow -eq 1 ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.overflow.bug;
        fi;


        if [ -e "log/$filename/id_$idx.$count" ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.bug;
        fi;

        export count=$(($count + 1)); 
        echo "#!/bin/bash">  log/$filename/bugs/id_$idx.count.tmp
        echo " export count="$count >>  log/$filename/bugs/id_$idx.count.tmp

        mv log/$filename/bugs/id_$idx.count.tmp log/$filename/bugs/id_$idx.count
    fi; 
     echo "script loop end"
done
echo "done"
echo $1" "$2" "$3" "$4" "$5" "$6" "${7}" "${8}" "${9}

#exit codes
#timeout:     124
#out of mem:  14



