#!/bin/bash

# sseeds - Updated 8.9.23 to personal ifarm environment

# -------------------------------------------------------------------------- #
# This script sets various environmet paths reuired by the "submit-" scripts #
# Environment paths are user specific, hence all the entries in this script  #
# have been kept in a templated format. User must modify the necessary paths #
# appropriately for proper execution of any process.                         #
# ---------                                                                  #
# P. Datta <pdbforce@jlab.org> CREATED 07-25-2023                            #
# ---------                                                                  #
# ** Do not tamper with this sticker! Log any updates to the script above.   #
# -------------------------------------------------------------------------- #

# Required by all
export SCRIPT_DIR=/w/halla-scshelf2102/sbs/seeds/jlab-HPC

# Required by the scripts running G4SBS simulations
export G4SBS=/w/halla-scshelf2102/sbs/seeds/sim/install

# Required by the scripts running SIMC (simc_gfortran) jobs
export SIMC=/w/halla-scshelf2102/sbs/seeds/simc_gfortran

# Required by the scripts running digitization jobs using sbsdig
export LIBSBSDIG=/w/halla-scshelf2102/sbs/seeds/dig/install

# Required by the scripts running replay (data or MC) jobs
export ANALYZER=/w/halla-scshelf2102/sbs/seeds/ANALYZER/install
export SBSOFFLINE=/w/halla-scshelf2102/sbs/seeds/SBS_OFFLINE/install
export SBS_REPLAY=/w/halla-scshelf2102/sbs/seeds/SBS_Replay_upstream/SBS-replay

#Path to data directories
#The path is written this way below becauses strings will need to be added to the left side of them, ie /cache/$GMN_DATA_PATH
export GMN_DATA_PATH=halla/sbs/raw
export GEN_DATA_PATH=halla/sbs/GEnII/raw
