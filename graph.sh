#!/bin/bash

PATH="/home/qbfreak/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/qbfreak/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/qbfreak/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/qbfreak/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/qbfreak/perl5"; export PERL_MM_OPT;

pushd /home/qbfreak/wx/ > /dev/null
/usr/bin/perl /home/qbfreak/wx/graph.pl KEQY > /dev/null
/usr/bin/perl /home/qbfreak/wx/graph.pl KORD > /dev/null
mv *.png /home/qbfreak/qbfreak.net/wx/
popd > /dev/null

