#!/bin/bash
<< '#################################################'
# Y88b   d88P   88888888888     d8888     88888888888 
#  Y88b d88P        888        d88888         888     
#   Y88o88P         888       d88P888         888     
#    Y888P  8888b.  888      d88P 888 888d888 888     
#     888      "88b 888     d88P  888 888P"   888     
#     888  .d888888 888    d88P   888 888     888     
#     888  888  888 888   d8888888888 888     888     
#     888  "Y888888 888  d88P     888 888     888     
#################################################
# Still very much to do!


# Path to mt
mt=$(which mt)
for i in {0..9}
do
    if [[ -e /dev/nst$i ]]
    then
        tape="/dev/nst$i"
    fi
done
mt="$(echo $mt -f $tape)"


# A few general functions
function get_file { $mt status | grep 'File number' | cut -d',' -f1 | sed 's/[^0-9]*//g'; }
function get_block { $mt status | grep 'block number' | cut -d',' -f2 | sed 's/[^0-9]*//g'; }
function get_part { $mt status | grep 'partition' | cut -d',' -f3 | sed 's/[^0-9]*//g'; }
function get_status { $mt status | grep -A1 'General status bits on' | tail -n1 | sed 's/ //'; }
function rewind { $mt rewind; }
function eject { $mt offline; }
function erase { $mt erase; }
function fsf { $mt fsf $1; }
function fsfm { $mt fsf $1; }
function bsf { $mt fsf $1; }
function bsfm { $mt fsf $1; }

# A few more complex functions
function goto_file {
    goto=$1
    file=get_file
    if [[ $goto -gt $file ]]
    then
        trip=$(( $goto - $file ))
        fsf $trip
    elif [[ $goto -lt $file ]]
    then
        trip=$(( $file - $goto + 1 ))
        bsfm $trip
    fi
}

function goto_currentEOF {
    get_status | grep -q EOF
    if [[ $? -ne 0 ]]
    then
        bsfm
    fi
}

function get_tapeID {
    rewind
    tar -t
}
