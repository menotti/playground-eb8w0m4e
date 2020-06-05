#!/bin/sh

sample=$1


cd /project/target/src/exercises/

g++ ${sample}.cpp -o $sample -I${OCL_INC} -lOpenCL -L${OCL_LIB} -Wdeprecated-declarations

#export COMPUTECPP_TARGET=cpu # host

./$sample
