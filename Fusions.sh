#!/bin/bash
#=====================================================================
# Christopher S. Trethewey, chris.s.trethewey{@outlook.com
# Fusion detect pipline for PanLymphv2, argetted CAPP-seq, WES and WGS
# 2022
#=====================================================================


# Dependancies to add to PATH ----------------------------------------
# samtools
# - After downloading, find samtools and copy/link/move to PATH (i.e., /usr/bin).
# blast+
# -After downloading, find blastn and makeblastdb in ncbi-blast-version/bin and copy/link/move to PATH (i.e., /usr/bin)
#twoBitToFa
# Download from UCSC here: http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/
# perl:
# -install: Sudo cpan Statistics::Descriptive
# -Other: IPC::Open3, List::Util, File::Spec, Symbol, Getopt::Std, File::Basename

# perl factera.pl [options] tumor.bam exons.bed hg19.2bit [optional: targets.bed]

echo ''
echo ''
echo '     _______________D_E_L_V_E_______________ '
echo '    /                                       |'
echo '    \       Christoper Simon Trethewey      |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \           Fusions Dectection          |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \              version 2.00             |'
echo '    /              GenVerGrCH37             |'
echo '    \                                       |'
echo '    /                FACTERA                |'
echo '    /              Newman et al.            |'
echo '    \    DOI:10.1093/bioinformatics/btu549  |'
echo '    /              Samtools/1.9             |'
echo '    /_________________________F_U_S_I_O_N___|'
echo ''
echo ''

SAMPLELIST=$1
DATADIR=$2
GENOME=$3

   echo "TUMOUR sample list defined =  $1"
   echo "BamDirectory = $2"
   echo "Genome version = $3"


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
-r 10 -m 5 -s 2-c 10 \
$DATADIR/${ID}_dD-RG-BQSR_FINAL.bam \
/Delve/RESOURCE/$GENOME/exons.bed \
/Delve/RESOURCE/genomes/$GENOME/*.fa.2bit


echo ""
echo 'completed running FACTERA v1.4.4 on sample' ${ID}
echo ""

done
