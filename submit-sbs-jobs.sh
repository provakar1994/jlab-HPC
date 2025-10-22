#!/bin/bash

# ------------------------------------------------------------------------- #
# This script submits a single job for real data analysis. It should be     #
# called by sbs-replay-main.sh.                                             #
# ---------                                                                 #
# P. Datta <pdbforce@jlab.org> CREATED 11-09-2022                           #
# Sean Jeffas <sj9ry@virginia.edu> Updated 07-25-2023                       #
# ---------                                                                 #
# ** Do not tamper with this sticker! Log any updates to the script above.  #
# ------------------------------------------------------------------------- #

runnum=$1
prefix=$2
nevents=$3
maxsegments=$4
segments_per_job=$5
use_sbs_gems=$6
run_on_ifarm=$7
outdirpath=$8
workflowname=$9
scriptdir=${10}
analyzerenv=${11}
sbsofflineenv=${12}
sbsreplayenv=${13}
datapath=${14}
ANAVER=${15}     # Analyzer version
useJLABENV=${16} # Use 12gev_env instead of modulefiles?
JLABENV=${17}    # /site/12gev_phys/softenv.sh version

#Set environments from inputs above
export SCRIPT_DIR=$scriptdir
export ANALYZER=$analyzerenv
export SBSOFFLINE=$sbsofflineenv
export SBS_REPLAY=$sbsreplayenv
export DATA_PATH=$datapath
export DATA_DIR=/cache/$DATA_PATH

firstsegment=0
lastsegment=0
nsegments=0
firststream=0
laststream=0
nstreams=0

# look for first segment of first stream on cache disk:
firstsegname=$prefix'_'$runnum'.evio.0.0'
mssfirst='mss:/mss/'$DATA_PATH/$firstsegname
cachefirst='/cache/mss/'$DATA_PATH/$firstsegname

script=$SCRIPT_DIR'/run-sbs-replay.sh'

# no matter what we require the first stream, first segment for each job (must exist)
# so we initialize input string to the first segment of first stream:
inputstring=' -input '$cachefirst' '$mssfirst' '

for ((i=0; i<=$maxsegments; i++))
do

    segment_i_added=0 # this will be set to 1 if at least segment i stream 0 is found:
    
    if(( $nsegments == 0 )); then # we haven't added any segments to this job yet:
	# initialize firstsegment and inputstring:
	firstsegment=$i
	inputstring=' -input '$cachefirst' '$mssfirst' '
    fi

    # look for streams zero through 2 for segment i: $i is segment number $j is stream number
    for((j=0; j<=2; j++))
    do 
	eviofilename=$prefix'_'$runnum'.evio.'$j'.'$i
	mssfilename='mss:/mss/'$DATA_PATH/$eviofilename
	cachefile='/cache/mss/'$DATA_PATH/$eviofilename

	testfilename='/mss/'$DATA_PATH/$eviofilename

	firststream=$j
	maxstream=$j
	
	if [ -f "$testfilename" ]; 
	then
	    if(( $j == 0 )); then
		(( nsegments++ ))
		segment_i_added=1
	    fi
	    if(( !($j == 0 && $i == 0) )); then # unless this is the first segment of stream 0, add the file to the job:
		if [[ $prefix == "gep5" ]]; then
		    inputstring=' -input '$cachefirst' '$mssfirst' '
		    inputstring+=' -input '$cachefile' '$mssfilename' '
		else
		    inputstring+=' -input '$cachefile' '$mssfilename' '
		fi
	    fi
	    jobname=$prefix'_replay_'$runnum'_segment'$i'_stream'$j
	    echo 'Submitting job '$jobname' with '$nsegments' segments, runnum='$runnum

	    scriptrun=$script' '$j' '$j' '$runnum' '$nevents' 0 '$prefix' '$i' 1 '$use_sbs_gems' '$DATA_PATH' '$outdirpath' '$run_on_ifarm' '$ANALYZER' '$SBSOFFLINE' '$SBS_REPLAY' '$ANAVER' '$useJLABENV' '$JLAB
	    addjobcmd='add-job -workflow '$workflowname' -partition production -name '$jobname' -cores 1 -disk 25GB -ram 3000MB '$inputstring' '$scriptrun
	    
	    if [[ $run_on_ifarm -ne 1 ]]; then
	        swif2 $addjobcmd
		#echo $addjobcmd
	    else
		$scriptrun
	    fi
	fi
	
#	if [[ $prefix == "gep5" && -f "testfilename" ]]; then
	  
#	    jobname=$prefix'_replay_'$runnum'_segment'$i'_stream'$j
#	    echo 'Submitting job '$jobname' with '$nsegments' segments, runnum='$runnum
#	    #echo 'Input string = '$inputstring
#	    
#	    #scriptrun=$script' '$firststream' '$maxstream' '$runnum' '$nevents' 0 '$prefix' '$firstsegment' 1 '$use_sbs_gems' '$DATA_PATH' '$outdirpath' '$run_on_ifarm' '$ANALYZER' '$SBSOFFLINE' '$SBS_REPLAY' '$ANAVER' '$useJLABENV' '$JLAB
#	    scriptrun=$script' '$j' '$j' '$runnum' '$nevents' 0 '$prefix' '$i' 1 '$use_sbs_gems' '$DATA_PATH' '$outdirpath' '$run_on_ifarm' '$ANALYZER' '$SBSOFFLINE' '$SBS_REPLAY' '$ANAVER' '$useJLABENV' '$JLAB
#	    addjobcmd='add-job -workflow '$workflowname' -partition production -name '$jobname' -cores 1 -disk 25GB -ram 3000MB '$inputstring' '$scriptrun
	    
#	    if [[ $run_on_ifarm -ne 1 ]]; then
#	        swif2 $addjobcmd
#		#echo $addjobcmd
#	    else
#		$scriptrun
#	    fi
#	    #nsegments=0
#	fi
	  
    done # end loop on streams 0-2
    
    # After adding any files found from this segment number to the job,
    # check if this is the last segment or if adding this segment caused us to reach the target number of segments per job:
    if [[ $segment_i_added -eq 1 && $prefix != "gep5" ]]; then
    #if(( $segment_i_added == 1 )); then # if we at least found stream 0 for this segment, proceed: 
	if (( $i == $maxsegments || $nsegments == $segments_per_job )); 
	    then # this is either the last segment or we reached the required number of segments per job. 
	    # Go ahead and launch the job and then reset segment counter:
	    lastsegment=$i 
	    jobname=$prefix'_replay_'$runnum'_segments'$firstsegment'_'$lastsegment
	    
	    echo 'Submitting job '$jobname' with '$nsegments' segments, runnum='$runnum
	    #echo 'Input string = '$inputstring
	    
	    scriptrun=$script' 0 0 '$runnum' '$nevents' 0 '$prefix' '$firstsegment' '$nsegments' '$use_sbs_gems' '$DATA_PATH' '$outdirpath' '$run_on_ifarm' '$ANALYZER' '$SBSOFFLINE' '$SBS_REPLAY' '$ANAVER' '$useJLABENV' '$JLABENV
	    #echo 'Script Run = '$scriptrun
	    addjobcmd='add-job -workflow '$workflowname' -partition production -name '$jobname' -cores 1 -disk 25GB -ram 3000MB '$inputstring' '$scriptrun
	    
	    if [[ $run_on_ifarm -ne 1 ]]; then
	        swif2 $addjobcmd
		#echo $addjobcmd
	    else
		$scriptrun
	    fi

       	    nsegments=0
	fi   
    else # current segment NOT added; if any segments have been added to the job, go ahead and submit the job if applicable
        if [[ $nsegments -gt 0 && $prefix != "gep5" ]]; then
	    ((lastsegment=$i-1))
	    jobname=$prefix'_replay_'$runnum'_segments'$firstsegment'_'$lastsegment
	    
	    echo 'Submitting job '$jobname' with '$nsegments' segments, runnum = '$runnum
#	    echo 'Input string = "'$inputstring'"'

	    scriptrun=$script' 0 0 '$runnum' '$nevents' 0 '$prefix' '$firstsegment' '$nsegments' '$use_sbs_gems' '$DATA_PATH' '$outdirpath' '$run_on_ifarm' '$ANALYZER' '$SBSOFFLINE' '$SBS_REPLAY' '$ANAVER' '$useJLABENV' '$JLABENV
	    addjobcmd='add-job -workflow '$workflowname' -partition production -name '$jobname' -cores 1 -disk 25GB -ram 3000MB '$inputstring' '$scriptrun

	    if [[ $run_on_ifarm -ne 1 ]]; then
	        swif2 $addjobcmd
		#echo $addjobcmd
	    else
		$scriptrun
	    fi

	    nsegments=0
	fi
	#break
    fi
done
