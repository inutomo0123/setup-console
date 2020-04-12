#!/bin/bash

set -Cuex

function step1(){

    sudo apt install exuberant-ctags

    pip3 install --user Pygments
}

function step2(){
    mkdir ${HOME}/local/src

    cd ${HOME}/local/src
    wget http://tamacom.com/global/global-6.6.4.tar.gz

    tar -zxvf global-6.6.4.tar.gz

    cd ./global-6.6.4

    ./configure prefix=${HOME}/local
    make
    make install
}

function step3(){

    cp -i  ${HOME}/local/share/gtags/gtags.conf ${HOME}/.globalrc

    sed -i 's/^\t:tc=native:/&tc=pygments:/g' ${HOME}/.globalrc
}

step1
step2
step3
