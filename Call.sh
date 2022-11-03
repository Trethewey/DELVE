#!/bin/bash
#=====================================================================
# Christopher S. Trethewey, chris.s.trethewey{@outlook.com
# Variant calling pipline for WES and Targetted Sequencing Data.
# GATKv4.0.3.0 - Mutect2 / FilterMutectCalls / vcf2Maf.
#2022
#=====================================================================

echo ''
echo ''
echo '     _______________D_E_L_V_E_______________ '
echo '    /                                       |'
echo '    \       Christoper Simon Trethewey      |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \       Variant Call & Annotation       |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \                                       |'
echo '    \              Picard/2.6.0             |'
echo '    /              VEP/108                  |'
echo '    \              Samtools/1.8             |'
echo '    /              GATK/4.1.5.0             |'
echo '    \              Vcf2Maf/1.6.20           |'
echo '    \              Perl/5.24.0              |'
echo '    \                                       |'
echo '    /__________C_A_L_L__&__A_N_N_O_T_A_T_E__|'
echo ''
echo ''

TUMOURLIST=$1
DATADIR=$2
N=$3
GENOME=$4
NGStype=$5
OUTPUTDIR=$6

if [ $# -eq 0 ]
  then
    echo ' **undefined sample list and Bam directory**'
    echo ''
    echo 'exiting'
    echo ''
    echo 'usage: CALL_v3 [TUMOURLIST] [Bam location] [Germline Bam ID] [Genome version] [NGS type (WES,CAPPSEQ)] [Output directory]'
    echo ''
    exit 1
fi
echo "TUMOUR sample list =  $1"
echo "BamDirectory = $2"
echo "GERMLINE sample = $3"
echo "Genome version = $4"
echo "Sequencing type = $5"

mkdir $OUTPUTDIR/CALL
mkdir $OUTPUTDIR/RPT

Ts=$(cat $TUMOURLIST)

   echo "#####################################################"
   echo ""
   echo "PATIENTIDS specified in SAMPLELIST:"
   echo "$Ts"
   echo ""
   echo "Germiline sample specified"
   echo "$N"
   echo ""
   echo "#####################################################"

for T in $Ts
do

echo 'running mutect on'
echo $T

gatk Mutect2 \
-R /Delve/RESOURCE/genomes/$GENOME/*.fa \
-L /Delve/RESOURCE/$NGStype/interval_list/*.bed \
-I $DATADIR${T}_dD-RG-BQSR_FINAL.bam \
-I $DATADIR${N}_dD-RG-BQSR_FINAL.bam \
-tumor ${T} \
-normal ${N} \
--disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
--germline-resource /Delve/RESOURCE/genomes/$GENOME/*af-only-gnomad.vcf.gz \
-O $OUPUTDIR/CALL/${T}.mutect2.vcf.gz

echo 'filtering mutect calls for sample'
echo $T
echo ""
gatk \
FilterMutectCalls \
-V $OUPUTDIR/CALL/${T}.mutect2.vcf.gz \
-R /Delve/RESOURCE/genomes/$GENOME/*.fa \
-O $OUPUTDIR/CALL/${T}.mutect2_filtered.vcf.gz

echo "calculating contamination in sample"
echo $T
echo ""

gatk \
GetPileupSummaries \
-L /Delve/RESOURCE/$NGStype/interval_list/*.bed \
-I ${T}_dD-RG-BQSR_FINAL.bam \
-V /Delve/RESOURCE/genomes/$GENOME/*af-only-gnomad.vcf.gz \
-O $PWD/RPT/${T}_pileupsummaries.table

gatk \
CalculateContamination \
-I $PWD/RPT/${T}_pileupsummaries.table \
-O $PWD/RPT/${T}_GATKcontamination_calc.table

#----------------------------------------------------------------------------------

gunzip $PWD/CALL/${T}.mutect2_filtered.vcf.gz

echo "annotating with maftools"
echo $T
echo ""

perl \
/Delve/programs/vcf2maf/vcf2maf-1.6.20/vcf2maf.pl \
--input-vcf $PWD/CALL/${T}.mutect2_filtered.vcf \
--ref-fasta /Delve/RESOURCE/genomes/$GENOME/*.fa \
--vep-forks 16 \
--vep-path $VEPPATH \
--vep-data $VEPDATA \
--filter-vcf /Delve/RESOURCE/genomes/$GENOME/ExAC_nonTCGA.sites.vep.vcf.gz \
--buffer-size 100 \
--vcf-tumor-id ${T} \
--vcf-normal-id ${N} \
--tumor-id ${T} \
--normal-id ${N} \
--output-maf $PWD/CALL/${T}_mutect2.maf

done
