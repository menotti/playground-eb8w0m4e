#!/bin/sh

echo lscpu output:
lscpu

echo dmidecode output:
dmidecode --type memory 

echo free output:
free -h 

echo clinfo output:
clinfo
