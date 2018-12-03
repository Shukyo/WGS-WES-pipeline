#!/bin/bash -e
dir=`dirname $0`
source $dir/dna_analysis.defFun # defined the functions
source $dir/dna_analysis.defRef # defined the default parameters
source $dir/dna_analysis.help # defined the help document
source $dir/dna_analysis.defInput # recieve the external parameters
source $dir/dna_analysis.check # check the refer/input files
source $dir/dna_analysis.printHead # output the basic information for the run
source $dir/dna_analysis.run # main programe
