#!/bin/sh

sample=$1

cd /project/target/src/exercises/

g++ -Wdeprecated-declarations ${sample}.cpp -o $sample -I${OCL_INC} -lOpenCL -L${OCL_LIB} -I. 

./$sample
