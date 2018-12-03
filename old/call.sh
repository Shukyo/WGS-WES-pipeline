######################################################################
##SNP discovery##
#################

#---------------------------------------------------------------------
#SNP calling

if [ ! -s $wd/snps.vcf ];then
	echo "#Begin to call variants at `date`"
java    -jar $GATK -T UnifiedGenotyper \
	-glm BOTH \
	-R $hg19 \
	-I $wd/accepted.bam \
	-D $dbsnp \
	-o $wd/snps.vcf 
fi
##################################################################
#filter SNPs and cutoff

if [ ! -s $wd/filtered_snps.vcf ];then
	echo "#Begin to filter out dbsnp and potential false positive sites at `date`"
java    -jar $GATK -T VariantFiltration\
	-V $wd/snps.vcf \
	-R $hg19 \
	-o $wd/filtered_snps.vcf \
	--clusterWindowSize 10 \
	--filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
	--filterName "HARD_TO_VALIDATE" \
	--filterExpression "DP < 5 " \
	--filterName "LowCoverage" \
	--filterExpression "QUAL < 30.0 " \
	--filterName "VeryLowQual" \
	--filterExpression "QUAL > 30.0 && QUAL < 50.0 " \
	--filterName "LowQual" \
	--filterExpression "QD < 1.5 " \
	--filterName "LowQD" \
	--filterExpression "SB > -10.0 " \
        --filterName "StrandBias"
fi
#clusterWindowSize	>=3 filters within 10 base-pairs these are flagged as SnpCluster(likely to be false positives) 
#HARD_TO_VALIDATE	>=4 alignments or 10% alignments  having a mapping quality of MQ0 (maps to different locations equally well)
#LowCoverage	DP < 5 
#VeryLowQual	QUAL < 30.0
#LowQual	30.0< QUAL <50.0
#LowQD		QD <1.5 Variant confidence (given as (AB+BB)/AA from the PLs) /unfiltered depth (false positive calls and artifacts)
#StrandBias	SB>-10.0 SNPs covered only by sequences on the same strand are often artifacts.

#############################################################
#Annotations using annovar
#db=/PATH/humandb
#if [ ! -e $wd/annovar ];then
#	mkdir $wd/annovar
#fi
#convert2annovar.pl --format vcf4 --includeinfo $wd/filtered.vcf > input.annovar
#annotate_variation.pl --buildver hg19 input.annovar $db -outfile $wd/annovar/snp

