#!/bin/bash

set -Cue

SRC_DIR="${HOME}/local/src/"
LOCAL_DIR="${HOME}/local/"
BIN_DIR="${HOME}/local/bin/"

SERIAL="$(date +%Y%m%d%H%M%S)"

GNUGLOBAL_VERSION="6.6.5"

# Pygments
function pygments-setup(){

    sudo apt update

    # ctagのインストール
    sudo apt install exuberant-ctags

    # pythonのバージョンによる分岐
    python_version=$(python --version 2>&1 \
                         | grep -o "[2,3]\.[0-9]\.[0-9]")

    if [ "${python_version:0:1}" = "2" ]; then
        forpython2
    else
        forpython3
    fi
}

function forpython3(){

    # pipのインストール
    sudo apt install python3-pip

    # Pygmentsのインストール
    pip3 install --user Pygments

}

function forpython2(){

    # pipのインストール
    sudo apt install python-pip

    # Pygmentsのインストール
    pip install --user Pygments
}

# GNU GLOBAL
function gnuglobal-setup(){

    sudo apt install build-essential libncurses-dev

    mkdir -p "${SRC_DIR}"

    cd "${SRC_DIR}"
    wget "http://tamacom.com/global/global-${GNUGLOBAL_VERSION}.tar.gz"

    tar -zxvf "global-${GNUGLOBAL_VERSION}.tar.gz"

    cd "./global-${GNUGLOBAL_VERSION}"

    ./configure prefix="${LOCAL_DIR}"
    make
    make install
}

function gnuglobal-setting(){

    # ~/.globalrc
    if [ -f "${HOME}/.globalrc" ]; then
       mv "${HOME}/.globalrc" "${HOME}/.globalrc.${SERIAL}"
    fi

    cp -i  "${HOME}/local/share/gtags/gtags.conf" "${HOME}/.globalrc"

    sed -i 's/^\t:tc=native:/&tc=pygments:/g' "${HOME}/.globalrc"

    # PATH
    if [ -f "${HOME}/.bashrc" ] ; then

        cp "${HOME}/.bashrc" "${HOME}/.bashrc.${SERIAL}"

        cat <<EOF >> "${HOME}/.bashrc"

# GNU GLOBAL
PATH="${BIN_DIR}:\${PATH}"
EOF
    fi
}

pygments-setup
gnuglobal-setup
gnuglobal-setting
