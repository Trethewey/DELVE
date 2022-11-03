#!/bin/bash
echo ''
echo ''
echo '     _______________D_E_L_V_E_______________ '
echo '    |                                       |'
echo '    |       Christoper Simon Trethewey      |'
echo '    |       ><><><><><><><><><><><><><      |'
echo '    |       Immunoglobulin   Repitoire      |'
echo '    |                Analysis               |'
echo '    |       ><><><><><><><><><><><><><      |'
echo '    |                                       |'
echo '    |              version 2.0              |'
echo '    |                                       |'
echo '    |          vidjil-algo/2021.02.2        |'
echo '    |          http://www.vidjil.org        |'
echo '    |          Bonsai bioinformatics        |'
echo '    |                                       |'
echo '    |____________________________I_G_H_V____|'
echo ''
echo ''
BamList=$1
OUTPUTDIR=$2
GENOME=$3
if [ $# -eq 0 ]
  then
    echo ""
    echo "** ERROR: No arguments supplied, please specify Bamlist, output directory and genome version"
    echo "** e.g. sh Vidjil.sh BamList OutputDir hg38"
    echo""
    exit 1
fi
Bamfiles=$(cat $BamList)
   echo "#####################################################"
   echo ""
   echo "		Bamfiles specified in Bamlist:"
   echo ""
   echo "$Bamfiles"
   echo ""
   echo "#####################################################"
for Bamfile in $Bamfiles
   do
   echo ""
   echo "Running IGHV analysis on $Bamfile"
   echo ""
   echo ""
/Delve/programs/Vidjil/vidjil-algo-2021.02.2/vidjil-algo \
-c clones \
-g /Delve/RESOURCE/genomes/$GENOME/vidjil.homo-sapiens.g \
-2 -3 -r 1 \
$Bamfile \
--dir $OUTPUTDIR
   echo ""
   echo ""
   echo " Completed IGHV analysis on $Bamfile."

done
