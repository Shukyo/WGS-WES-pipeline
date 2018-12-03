#global--------------------------------------------------------------------
export hg19=/database/GATK/ucsc.hg19.fasta
export wd=/home/shuy/test
#alignment----------------------------------------------------------------
export bwaref=/database/iGenome/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa
export prefix=/database/iGenome/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome
export fq1=$wd/1.fq
export fa2=$wd/2.fq
export thread=20
export sample="Sample1"
export readgroup="@RG\tID:$sample\tLB:$sample\tSM:$sample\tPL:ILLUMINA"
#GATK----------------------------------------------------------------------
export picard=/database/GATK/picard.jar
export GATK=/database/GATK/GenomeAnalysisTK.jar
export dbsnp=/database/GATK/dbsnp_138/dbsnp_138.hg19.vcf
export indel=/database/GATK/indels
export temp=$wd/temp
#--------------------------------------------------------------------------
export annovardb=/database/annovar/humandb

#sh align.sh
sh gatk.sh
#sh call.sh


