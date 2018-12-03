######################################################################
##Pre-processing##
##################

if [ ! -e $wd/temp ];then
	mkdir $wd/temp
fi

#---------------------------------------------------------------------
#Sam2Bam & sort

if [ ! -s $wd/sorted.bam ];then
	echo "#Begin to sort sam at `date`"
java    -Djava.io.tmpdir=$temp \
	-jar $picard SortSam \
        SO=coordinate \
	INPUT=$wd/aln.sam.gz \
	OUTPUT=$wd/sorted.bam \
	VALIDATION_STRINGENCY=LENIENT \
	CREATE_INDEX=true
fi
#SO: sort order(unsorted, queryname, coordinate) 
#VALIDATION_STRINGENCY=LENIEN: picard ignores some validation errors which frequently occur at the alignment step
#CREATE_INDEX=true: automatically create an index file for the generated bam file

#---------------------------------------------------------------------
#Marking PCR duplicates
if [ ! -s $wd/dedup.bam ];then
	echo "#Begin to mark duplicates at `date`"
java    -Djava.io.tmpdir=$temp \
	-jar $picard MarkDuplicates \
	INPUT=$wd/sorted.bam \
	OUTPUT=$wd/dedup.bam \
	METRICS_FILE=$wd/metrics.txt \
	CREATE_INDEX=true \
	VALIDATION_STRINGENCY=LENIENT
fi

#VALIDATION_STRINGENCY=LENIENT  因为paired reads有一条比对到染色体的末端时，另外一条picard无法识别就会报错终止运行

#---------------------------------------------------------------------
#-------------Local realignment around indels-------------------------
#step1:creates a table of possible indels

if [ ! -s $wd/indel.bam.list ];then
	echo "#Begin creates a table of possible indels at `date`"
java    -jar $GATK -T RealignerTargetCreator \
	-R $hg19 \
	-o $wd/indel.bam.list \
	-I $wd/dedup.bam \
        -known $indel/1000G_phase1.indels.hg19.sites.vcf \
	-known $indel/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf

fi

#step2:realigns reads around those targets:

if [ ! -s $wd/realigned.bam ];then
	echo "#Begin to realigns reads around those targets sam at `date`"
java    -Djava.io.tmpdir=$temp \
	-jar $GATK -T IndelRealigner\
	-I $wd/dedup.bam \
	-R $hg19 \
	-targetIntervals $wd/indel.bam.list \
	-o $wd/realigned.bam \
        -known $indel/1000G_phase1.indels.hg19.sites.vcf \
	-known $indel/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf
fi

#---------------------------------------------------------------------
#Base quality score recalibration
#step1:create recal.grp for recalibration

if [ ! -s $wd/recal.grp ];then
	echo "#Begin to create recal.grp at `date`"
java    -jar $GATK  -T BaseRecalibrator \
	-R $hg19 \
	-I $wd/realigned.bam \
        -knownSites $indel/1000G_phase1.indels.hg19.sites.vcf \
	-knownSites $indel/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-knownSites $dbsnp \
	-o $wd/recal.grp 
fi

#step2:create the post-recalibration pdf 
if [ ! -s $wd/post_recal.grp ];then
	echo "#Begin to create post-recal.grp at `date`"
java    -jar $GATK -T BaseRecalibrator \
	-R $hg19 \
	-I $wd/realigned.bam \
	-BQSR $wd/recal.grp \
	-o $wd/post_recal.grp \
        -knownSites $indel/1000G_phase1.indels.hg19.sites.vcf \
	-knownSites $indel/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-knownSites $dbsnp 
fi

#step3: Recalibration
if [ ! -s $wd/accepted.bam ];then
	echo "#Begin to recalibration at `date`"
java    -Djava.io.tmpdir=$temp \
	-jar $GATK  -T PrintReads \
	-R $hg19 \
	-I $wd/realigned.bam \
	-BQSR $wd/recal.grp \
	-o  $wd/accepted.bam
fi
