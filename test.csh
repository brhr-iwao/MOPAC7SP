#!/bin/csh
set job = $1
foreach file (out log brz gpt esp ump arc syb end)
    if -e $job.$file mv $job.$file $job.$file.$$
  end
if !(-e $job.log) mkfile -n 1 $job.log
setenv FOR005 $job.dat
setenv FOR006 $job.out
setenv FOR009 $job.res
setenv FOR010 $job.den
setenv FOR011 $job.log
setenv FOR012 $job.arc
setenv FOR013 $job.gpt
setenv FOR016 $job.syb
setenv FOR020 $job.ump
setenv SETUP  SETUP.DAT
setenv SHUTDOWN $job.end
time ./mopac $job <$job.dat 
#time mopac.exe $job <$job.dat &
#sleep 5
#tail -67f $job.out
vi $job.out
if -e core rm core
