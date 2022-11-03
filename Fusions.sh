#!/bin/bash
#=====================================================================
# Christopher S. Trethewey, chris.s.trethewey{@outlook.com
# Fusion detect pipline for PanLymphv2, argetted CAPP-seq, WES and WGS
#=====================================================================

module load samtools
module load blast+
module load perl

echo ''
echo ''
echo ''
echo ''
echo ''
echo '     _______________D_E_L_V_E_______________ '
echo '    /                                       |'
echo '    \       Christoper Simon Trethewey      |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \           Fusions Dectection          |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \                                       |'
echo '    /              version 2.00             |'
echo '    \                                       |'
echo '    /              GenVerGrCH37             |'
echo '    \                                       |'
echo '    /              BWA  /0.7.17             |'
echo '    \              Picard/2.6.0             |'
echo '    /              Samtools/1.8             |'
echo '    \              GATK/4.1.5.0             |'
echo '    /_________________________F_U_S_I_O_N___|'
echo ''
echo ''

SAMPLELIST=$1
DATADIR=$2

   echo "TUMOUR sample list defined =  $1"
   echo "BamDirectory = $2"
   echo ""

if [ $# -eq 0 ]
  then

    echo ' **undefined sample list and Bam directory**'
    echo ''
    echo 'exiting'
    echo ''
    echo 'usage: Fusions.sh TUMOURLIST BamDirectory'
    echo ''
    echo ''
    exit 1
fi

IDs=$(cat $SAMPLELIST)

   echo "#####################################################"
   echo ""
   echo "PATIENTIDS specified in SAMPLELIST:"
   echo ""
   echo "$IDs"
   echo ""
   echo "#####################################################"

for ID in $IDs

do

echo 'running FACTERA v1.4.4 on sample' ${ID}

perl /Delve/factera-v1.4.4/factera.pl \
$DATADIR/${ID}_dD-RG-BQSR_FINAL.bam \
/Delve/RESOURCE/bedFiles/exons.bed \
/Delve/RESOURCE/genomes/hg19/ucsc.hg19.fa.2bit

echo ""
echo 'completed running FACTERA v1.4.4 on sample' ${ID}
echo ""

done
