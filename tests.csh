#!/usr/bin/tcsh
foreach x (*.dat)
    rm -rf temp
    mkdir temp
    cp $x temp/FOR005
    (cd temp ; ../mopac )
    cp temp/FOR006 $x:r.out
end
