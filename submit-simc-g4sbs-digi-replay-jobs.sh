#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs SIMC events on ifarm and then uses the output ROOT files #
# to submit corresponding g4sbs, sbsdig, and replay jobs to the batch farm. #
# There is a flag that can be set to run all the jobs on ifarm as well.     #
# ---------                                                                 #
# P. Datta <pdbforce@jlab.org> CREATED 04-19-2023                           #
# ---------                                                                 #
# ** Do not tamper with this sticker! Log any updates to the script below.  #
# ------------------------------------------------------------------------- #

# ------------------- Notes and Instructions (READ BEFORE EXECUTION) ---------------- #
# ----------------------------------------------------------------------------------- #
# 1. This script takes 5 arguments:                                                   #
#    a. SIMC infile w/o file extention. Must be located at $SIMC/infiles directory.   #
#    b. SBS configuration (Valid options: 4,7,11,14,8,9)                              #
#    c. First job id.                                                                 #
#    d. Total no. of jobs to submit.                                                  #
#    e. Flag to force all jobs to run on ifarm. (1=>YES) Very useful for debugging.   #
# 2. Total no. of events per g4sbs job gets determined by SIMC infile ("ngen" flag)   #
# 3. Be sure to edit "workflowname" variable appropriately before executing script.   #
# 4. Be sure to edit "outdirpath" variable appropriately before executing script.     #
# 6. SIMC jobs get executed on ifarm (not on batch farm) and all the output files get #
#    moved to $outdirpath/simcoutdir directory.                                       #
# 7. After all the SIMC jobs are finished a summary CSV file, $infile_summary.csv get # 
#    created and kept in the directory mentioned above which contain the important    #
#    normalization factors for all jobs.                                              #
# 8. List of interdependencies: utility.py, run-g4sbs-w-simc.sh, run-sbsdig.sh,       #
#    run-digi-replay.sh | All these scripts must be present in the $SCRIPT_DIR        #
# ----------------------------------------------------------------------------------- #

# Setting necessary environments via setenv.sh
source setenv.sh

# ------ Variables needed to be set properly for successful execution ------ #
# -------------------------------------------------------------------------- #
# SIMC input file (don't add file extension). Must be located at $SIMC/infiles. 
# G4SBS macro should have same name as SIMC input file just with different 
# file extention and should be located at $G4SBS/scripts.
infile=$1
sbsconfig=$2    # SBS configuration (Valid options: 4,7,11,14,8,9)
# No. of jobs to submit (NOTE: # events to generate per job get set by SIMC infile ("ngen" flag))
fjobid=$3       # first job id
njobs=$4        # total no. of jobs to submit 
run_on_ifarm=$5 # 1=>Yes (If true, runs all jobs on ifarm)
# ----/\---- Above variables are taken as arguments to this script ---/\---- # 
# Workflow name
workflowname=sbs8_0p_simc_deen
# Specify a directory on volatile to store simc, g4sbs, sbsdig, & replayed outfiles.
# Working on a single directory is convenient & safe for the above mentioned
# four processes to run coherently without any error.
outdirpath=/lustre19/expphy/volatile/halla/sbs/seeds/simc_test
# -------------------------------------------------------------------------- #

# Sanity check 0: Checking the environments
if [[ ! -d $SCRIPT_DIR ]]; then
    echo -e '\nERROR!! Please set "SCRIPT_DIR" path properly in setenv.sh script!\n'; exit;
elif [[ ! -d $SIMC ]]; then
    echo -e '\nERROR!! Please set "SIMC" path properly in setenv.sh script!\n'; exit;
elif [[ ! -d $G4SBS ]]; then
    echo -e '\nERROR!! Please set "G4SBS" path properly in setenv.sh script!\n'; exit;
elif [[ ! -d $LIBSBSDIG ]]; then
    echo -e '\nERROR!! Please set "LIBSBSDIG" path properly in setenv.sh script!\n'; exit;
elif [[ (! -d $ANALYZER) && ($useJLABENV -eq 1) ]]; then
    echo -e '\nERROR!! Please set "ANALYZER" path properly in setenv.sh script!\n'; exit;
elif [[ ! -d $SBSOFFLINE ]]; then
    echo -e '\nERROR!! Please set "SBSOFFLINE" path properly in setenv.sh script!\n'; exit;
elif [[ ! -d $SBS_REPLAY ]]; then
    echo -e '\nERROR!! Please set "SBS_REPLAY" path properly in setenv.sh script!\n'; exit;
fi

# Sanity check 1: Validating the number of arguments provided
if [[ "$#" -ne 5 ]]; then
    echo -e " \n --!!--\n ERROR! Illegal number of arguments!! \n ------"
    echo -e " This script takes 5 arguments: <infile> <sbsconfig> <fjobid> <njobs> <run_on_ifarm>"
    echo -e "  1. <infile>       : SIMC infile w/o file extention. Must be located at SIMC/infiles directory."
    echo -e "  2. <sbsconfig>    : SBS configuration (Valid options: 4,7,11,14,8,9)."  
    echo -e "  3. <fjobid>       : First job id."  
    echo -e "  4. <njobs>        : Total no. of jobs to submit."
    echo -e "  5. <run_on_ifarm> : 1=>Yes (If true, runs all jobs on ifarm)"
    echo -e " ------"
    echo -e ' ** Make sure "workflowname" & "outdirpath" variables are set properly in the script.'
    echo -e ' ** Read the "Notes and Instructions" block at the top of script for more information.\n'
    exit;
else 
    echo -e '\n------'
    echo -e ' Check the following variable(s):'
    if [[ $run_on_ifarm -ne 1 ]]; then
	echo -e ' "workflowname" : '$workflowname''
    fi
    echo -e ' "outdirpath"   : '$outdirpath' \n------'
    while true; do
	read -p "Do they look good? [y/n] " yn
	echo -e ""
	case $yn in
	    [Yy]*) 
		break; ;;
	    [Nn]*) 
		if [[ $run_on_ifarm -ne 1 ]]; then
		    read -p "Enter desired workflowname : " temp1
		    workflowname=$temp1
		fi
		read -p "Enter desired outdirpath   : " temp2
		outdirpath=$temp2		
		break; ;;
	esac
    done
fi

# Sanity check 2: Create the output directory if necessary
if [[ ! -d $outdirpath ]]; then
    { #try
	mkdir $outdirpath
    } || { #catch
	echo -e "\n!!!!!!!! ERROR !!!!!!!!!"
	echo -e $outdirpath "doesn't exist and cannot be created!\n"
	exit;
    }
fi

# Sanity check 3: Check for the existance of SIMC infile
simcmacro=$SIMC'/infiles/'$infile'.inp'
if [[ ! -f $simcmacro ]]; then
    echo -e "\n!!!!!!!! ERROR !!!!!!!!!"
    echo -e "SIMC infile, $simcmacro, doesn't exist! Aborting!\n"
    exit;
fi

# Sanity check 4: Finding matching G4SBS preinit macro for SIMC infile
g4sbsmacro=$G4SBS'/scripts/'$infile'.mac'
if [[ ! -f $g4sbsmacro ]]; then
    echo -e "\n!!!!!!!! ERROR !!!!!!!!!"
    echo -e "G4SBS preinit macro, $g4sbsmacro, doesn't exist! Aborting!\n"
    exit;
fi

# Creating a sub-directory (simcout) to keep all the SIMC outputs in one place
export simcoutdir=$outdirpath'/simcout'
if [[ ! -d $simcoutdir ]]; then
    mkdir $simcoutdir
fi

# Creating a CSV file to write a summary table of normalization factors by job
simcnormtable=$simcoutdir'/'$infile'_summary.csv'

# Reading SIMC infile ("ngen" flag) to determine no. of g4sbs events to generate
nevents=$(python3 $SCRIPT_DIR'/'utility.py 'grab_simc_param_value' $simcmacro 'ngen')
if [[ $nevents -lt 0 ]]; then
    echo -e "\n!!!!!!!! ERROR !!!!!!!!!"
    echo -e "Illegal no. of events! nevents = $nevents | Aborting!\n"
    exit;
else
    echo -e "\n ** $nevents g4sbs events will be generated per job!"
fi

# Creating the workflow
if [[ $run_on_ifarm -ne 1 ]]; then
    swif2 create $workflowname
else
    echo -e "\nRunning all jobs on ifarm!\n"
fi

# Choosing the right GEM config for digitization
gemconfig=0
if [[ ($sbsconfig -eq 4) || ($sbsconfig -eq 7) ]]; then
    gemconfig=12
elif [[ $sbsconfig -eq 11 ]]; then
    gemconfig=10
elif [[ ($sbsconfig -eq 14) || ($sbsconfig -eq 8) || ($sbsconfig -eq 9) ]]; then
    gemconfig=8
else
    echo -e "Enter valid SBS config! Valid options: 4,7,11,14,8,9"
    exit;
fi

# Loop to create jobs
for ((i=$fjobid; i<$((fjobid+njobs)); i++))
do
    # lets generate SIMC events first
    echo -e 'Generating SIMC events for job_'$i'.. [Will take a few seconds]'
    pushd $SIMC >/dev/null
    ./run_simc_tree $infile
    mv 'worksim/'$infile'.root' $simcoutdir'/'$infile'_job_'$i'.root' 
    mv 'outfiles/'$infile'_start_random_state.dat' $simcoutdir'/'$infile'_start_random_state_job_'$i'.dat'
    mv 'outfiles/'$infile'.geni' $simcoutdir'/'$infile'_job_'$i'.geni'
    mv 'outfiles/'$infile'.gen' $simcoutdir'/'$infile'_job_'$i'.gen'
    mv 'outfiles/'$infile'.hist' $simcoutdir'/'$infile'_job_'$i'.hist'
    mv 'runout/'$infile'.out' $simcoutdir'/'$infile'_job_'$i'.out'
    simcoutfile=$simcoutdir'/'$infile'_job_'$i'.root'
    popd >/dev/null

    # Abort if SIMC job wasn't successfull
    if [[ ! -f $simcoutfile ]]; then
	echo -e "\n!!!!!!!! ERROR !!!!!!!!!"
	echo -e "SIMC event generation failed! job_$i"
	exit;
    fi
    echo -e "\nSIMC event generation successful! job_$i\n"

    # time to write summary table with normalization factors
    if [[ ($i == 0) || (! -f $simcnormtable) ]]; then
    	python3 $SCRIPT_DIR'/'utility.py 'grab_simc_norm_factors' 'None' '1' > $simcnormtable
    fi
    python3 $SCRIPT_DIR'/'utility.py 'grab_simc_norm_factors' $simcoutdir'/'$infile'_job_'$i'.hist' '0' >> $simcnormtable

    # submitting g4sbs jobs using SIMC outfiles
    outfilebase=$infile'_job_'$i
    postscript=$infile'_job_'$i'.mac'
    g4sbsjobname=$infile'_job_'$i

    g4sbsscript=$SCRIPT_DIR'/run-g4sbs-w-simc.sh'' '$infile' '$postscript' '$nevents' '$outfilebase' '$outdirpath' '$simcoutfile' '$run_on_ifarm' '$G4SBS' '$ANAVER' '$useJLABENV' '$JLABENV

    if [[ $run_on_ifarm -ne 1 ]]; then
	swif2 add-job -workflow $workflowname -partition production -name $g4sbsjobname -cores 1 -disk 5GB -ram 1500MB $g4sbsscript
    else
	$g4sbsscript
    fi

    # now, it's time for digitization
    txtfile=$infile'_job_'$i'.txt'
    sbsdigjobname=$infile'_digi_job_'$i
    sbsdiginfile=$outdirpath'/'$outfilebase'.root'

    sbsdigscript=$SCRIPT_DIR'/run-sbsdig.sh'' '$txtfile' '$sbsdiginfile' '$gemconfig' '$run_on_ifarm' '$G4SBS' '$LIBSBSDIG' '$ANAVER' '$useJLABENV' '$JLABENV
    
    if [[ $run_on_ifarm -ne 1 ]]; then
	swif2 add-job -workflow $workflowname -antecedent $g4sbsjobname -partition production -name $sbsdigjobname -cores 1 -disk 5GB -ram 1500MB $sbsdigscript
    else
	$sbsdigscript
    fi

    # finally, lets replay the digitized data
    digireplayinfile=$infile'_job_'$i
    digireplayjobname=$infile'_digi_replay_job_'$i

    digireplayscript=$SCRIPT_DIR'/run-digi-replay.sh'' '$digireplayinfile' '$sbsconfig' '-1' '$outdirpath' '$run_on_ifarm' '$ANALYZER' '$SBSOFFLINE' '$SBS_REPLAY' '$ANAVER' '$useJLABENV' '$JLABENV
    
    if [[ $run_on_ifarm -ne 1 ]]; then
	swif2 add-job -workflow $workflowname -antecedent $sbsdigjobname -partition production -name $digireplayjobname -cores 1 -disk 5GB -ram 1500MB $digireplayscript
    else
	$digireplayscript
    fi
done

# keep a copy of SIMC job summary file in the $outdirpath as well
cp $simcnormtable $outdirpath

# run the workflow and then print status
if [[ $run_on_ifarm -ne 1 ]]; then
    swif2 run $workflowname
    echo -e "\n Getting workflow status.. [may take a few minutes!] \n"
    swif2 status $workflowname
fi
