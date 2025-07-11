#!/bin/bash

# 0) prepare SCRIP grid file
export PTNAME=SW002_16
export S_LAT=28.0
export N_LAT=36.0
export E_LON=73.0
export W_LON=82.0
export NX=32
export NY=36
export IMASK=1
export GRIDFILE=${work_path}/dat/SCRIPgrid_${PTNAME}_c${cdate}.nc

cd ${HOME}/CESM/clm5.0.36/tools/mkmapgrids
ncl mkscripgrid.ncl

# 1) generate atm/ocn mapping files
export ESMFMKFILE=${HOME}/software/esmf-7.0.2-gnu/lib/libO/Linux.gfortran.64.mpiuni.default/esmf.mk
export ESMFBIN_PATH=${HOME}/software/esmf-7.0.2-gnu/bin/binO/Linux.gfortran.64.mpiuni.default
cd ${HOME}/CESM/clm5.0.36/cime/tools/mapping/gen_mapping_files

./gen_cesm_maps.sh --fileocn ${GRIDFILE} --fileatm ${GRIDFILE} --typeocn regional --typeatm regional --nameocn ${PTNAME} --nameatm ${PTNAME} -rc

# 2) generate (atm/lnd) and (ocn/ice) domain files
cd ${HOME}/CESM/clm5.0.36/cime/tools/mapping/gen_domain_files/src
../../../configure --macros-format Makefile --mpilib mpi-serial --machine CentralAsia
. ./.env_mach_specific.sh
make

cd ${HOME}/CESM/clm5.0.36/cime/tools/mapping/gen_domain_files
./gen_domain -m ../gen_mapping_files/map_${PTNAME}_TO_${PTNAME}_aave.${cdate}.nc -o ${PTNAME} -l ${PTNAME}
ln -sf domain.ocn.${PTNAME}_${PTNAME}.${cdate}.nc domain.${PTNAME}.nc

# 3) Generate mapping files for clm surface dataset (since this is a non-standard grid)
export ESMFBIN_PATH=${HOME}/software/esmf-7.0.2-gnu/bin/binO/Linux.gfortran.64.mpiuni.default
export CSMDATA=${HOME}/CESM/inputdata
cd ${HOME}/CESM/clm5.0.36/tools/mkmapdata
./mkmapdata.sh --gridfile ${GRIDFILE} --res ${PTNAME} --gridtype regional

# 4) Generate clm surface dataset
cd ${HOME}/CESM/clm5.0.36/tools/mksurfdata_map
./mksurfdata.pl -res usrspec -usr_gname ${PTNAME} -usr_gdate ${cdate} -years 2010 -dinlc ${CSMDATA}
ln -sf surfdata_${PTNAME}_hist_16pfts_CMIP6_simyr2010_c${cdate}.nc surfdata_${PTNAME}.nc


