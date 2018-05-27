#!/usr/bin/tcsh
foreach x (*.out)
    tr "0" " " <$x >/tmp/old.$$
    tr "0" " " <new/$x >/tmp/new.$$
    diff -t /tmp/old.$$ /tmp/new.$$ >$x:r.diff
end
