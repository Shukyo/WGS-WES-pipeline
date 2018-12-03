######################################################################
##alignment##
#############

#---------------------------------------------------------------------
#index

if [ ! -s ${bwaref}.bwt ];then
        echo "#Begin to index the reference sequences at `date`"
	bwa index -a bwtsw -p $prefix $hg19 
fi

#---------------------------------------------------------------------
#align

if [ ! -s $wd/aln.sam.gz ];then
        echo "#Begin to align the reference sequences at `date`"
	bwa mem -t $thread  -P -M -R $readgroup   $bwaref  $fq1 $fq2 | gzip > $wd/aln.sam.gz 
fi

#-P perform SW to rescue missing hit for paired-end reads
#-M mark shorter split hits as secondary (for further GATK analysis)

