#!/bin/bash
# 2022
# This script is for the alignment and pre-processing of WES and targetted NGS data.

echo ''
echo ''
echo '     _______________D_E_L_V_E_______________ '
echo '    /                                       |'
echo '    \       Christoper Simon Trethewey      |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \       Alignment & Pre-processing      |'
echo '    /       ><><><><><><><><><><><><><      |'
echo '    \                                       |'
echo '    /              version 3.00             |'
echo '    \                                       |'
echo '    \                                       |'
echo '    /              BWA  /0.7.17             |'
echo '    \              Picard/2.6.0             |'
echo '    /              Samtools/1.8             |'
echo '    \              GATK/4.1.5.0             |'
echo '    /____________________________A_L_I_G_N__|'
echo ''
echo ''

SAMPLELIST=$1
DATADIR=$2
GENOME=$3

if [ $# -eq 0 ]
  then

    echo ' **undefined sample list and fastq directory**'
    echo ''
    echo 'exiting'
    echo ''
    echo ''
    echo ''
    echo 'usage: Align.sh /path/to/SAMPLELIST.txt /path/to/FQfiles/'
    echo ''
    echo ''
    echo ''
    echo ''
    echo 'exiting'
    exit 1
fi

mkdir ../$DATADIR SAM
mkdir ../$DATADIR TEMP
mkdir ../$DATADIR RPT

SAMDIR=$PWD/SAM

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

echo""
echo '(1) aligning'
echo $ID
echo 'to UCSC-hg19'
echo ''
bwa mem -M -t 32 /Delve/RESOURCE/$GENOME/*.fa \
$DATADIR/${ID}_1.fq.gz $DATADIR/${ID}_2.fq.gz > $SAMDIR/$ID.sam;

echo "(2) sorting and indexing..."
echo $ID
echo''
samtools view -@ 16 -bS $SAMDIR/$ID.sam | \
samtools sort -@ 16 -o $PWD/TEMP/${ID}_SI.bam
samtools index -@ 16 $PWD/TEMP/${ID}_SI.bam

echo "(3) removing duplicate reads..."
echo $ID
echo''

java -Xms128m -Xmx1024m -jar /Delve/programs/picard/2.6.0/picard.jar \
MarkDuplicates \
I=$PWD/TEMP/${ID}_SI.bam \
O=$PWD/TEMP/${ID}_dD.bam \
M=$PWD/RPT/${ID}_Picard_MarkDuplicates_metrics.txt \
CREATE_INDEX=true \
TMP_DIR=$PWD/TEMP/${ID}_TMP

echo "(4) sorting and indexing..."
echo $ID
echo''
samtools sort -@ 16 $PWD/TEMP/${ID}_dD.bam -o $PWD/TEMP/${ID}_dD_SI.bam
samtools index -@ 16 $PWD/TEMP/${ID}_dD_SI.bam

echo "(5) updating read groups for sample"
echo $ID
echo''

java -Xms128m -Xmx1024m -jar /Delve/programs/picard/2.6.0/picard.jar \
AddOrReplaceReadGroups \
I=$PWD/TEMP/${ID}_dD_SI.bam \
O=$PWD/TEMP/${ID}_dD-RG.bam \
RGID=$ID \
RGLB=$ID \
RGPL=ILLUMINA \
RGPU=Hiseq \
RGSM=$ID

echo "(6) sorting and indexing..."
echo $ID
echo''

samtools sort -@ 16 $PWD/TEMP/${ID}_dD-RG.bam -o $PWD/TEMP/${ID}_dD-RG_SI.bam
samtools index -@ 16 $PWD/TEMP/${ID}_dD-RG_SI.bam

echo "(7) generating BQSR table for sample"
echo $ID
echo''

gatk BaseRecalibrator \
-I $PWD/TEMP/${ID}_dD-RG_SI.bam \
--known-sites /Delve/RESOURCE/$GENOME/*dbsnp_138.sites_sorted.vcf \
-O $PWD/TEMP/${ID}_BQSR.table \
-R /Delve/RESOURCE/$GENOME/*.fa

echo "(8) applying BQSR to sample"
echo $ID
echo''

gatk ApplyBQSR \
-bqsr $PWD/TEMP/${ID}_BQSR.table \
-I $PWD/TEMP/${ID}_dD-RG_SI.bam \
-O $PWD/TEMP/${ID}_dD-RG-BQSR.bam

echo "(9) final sort and index for sample"
echo $ID
echo''

samtools sort -@ 16 $PWD/TEMP/${ID}_dD-RG-BQSR.bam -o $PWD/TEMP/${ID}_dD-RG-BQSR_FINAL.bam
samtools index -@ 16 $PWD/TEMP/${ID}_dD-RG-BQSR_FINAL.bam

mv $PWD/TEMP/${ID}_dD-RG-BQSR_FINAL.bam $PWD/${ID}_dD-RG-BQSR_FINAL.bam
mv $PWD/TEMP/${ID}_dD-RG-BQSR_FINAL.bam.bai $PWD/${ID}_dD-RG-BQSR_FINAL.bam.bai

done
