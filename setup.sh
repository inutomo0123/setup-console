#!/bin/bash

set -ue

WORK_DIR="/tmp/$(date +%Y%m%d%H%M%S)"

cd $(dirname $0)

# update
function step0(){
    sudo apt update
    sudo apt dist-upgrade -y
    sudo reboot
}

# bash_completionを有効化
function step1(){
    cat ./bash_completion >> ${HOME}/.bashrc
    source ${HOME}/.bashrc
}

# etckeeper
function setup-etckeeper(){
    sudo apt install -y etckeeper
}

# tmux
function setup-tmux(){
    # 依存パッケージ
    sudo apt install -y build-essential libncurses5-dev libevent-dev

    # ダウンロード
    mkdir -p ${WORK_DIR}
    cd ${WORK_DIR}
    curl -OL https://github.com/tmux/tmux/releases/download/3.0a/tmux-3.0a.tar.gz
    tar -zxvf tmux-3.0a.tar.gz

    # インストール
    cd tmux-3.0a
    ./configure --prefix="${HOME}/local"
    make
    make install

    # 設定
    cd $(dirname $0)
    cp -i ./.tmux.conf ${home}/

    # PATH
    cat <<EOF >> ${HOME}/.bashrc

# tmux
PATH="\${HOME}/local/bin:\${PATH}"
EOF
    source ${HOME}/.bashrc
}

# powerline/powerline
function setup-powerline(){

    # ダウンロード
    mkdir -p ${WORK_DIR}
    cd ${WORK_DIR}
    curl -OL https://github.com/powerline/powerline/archive/2.7.tar.gz
    tar -zxvf 2.7.tar.gz

    # インストール
    cd powerline-2.7
    mkdir -p ${HOME}/.config
    cp -r ./powerline ${HOME}/.config/

    mkdir -p ${HOME}/local/bin
    cp -r ./scripts/powerline-* ${HOME}/local/bin/

    # 設定
    cat <<EOF >> ${HOME}/.tmux.conf

# powerline
run-shell "powerline-daemon -q"
source "${HOME}/.config/powerline/bindings/tmux/powerline.conf"
EOF

    # PATH
    cat <<EOF >> ${HOME}/.bashrc

# powerline
PATH="\${HOME}/local/bin:\${PATH}"
EOF
    source ${HOME}/.bashrc
}

# emacs
function setup-emacs(){
    
    # 依存パッケージ
    sudo apt install -y build-essential libncurses5-dev libgnutls28-dev pkg-config mailutils

    # ダウンロード
    mkdir -p ${WORK_DIR}
    cd ${WORK_DIR}
    curl -OL http://gnu.mirrors.hoobly.com/emacs/emacs-26.3.tar.gz
    tar -zxvf emacs-26.3.tar.gz

    # インストール
    cd ./emacs-26.3
    ./configure --prefix=${HOME}/local --without-x
    make
    make install

}

function config-emacs(){

    # ダウンロード
    mkdir -p ${HOME}/repo.d
    cd ${HOME}/repo.d
    git clone https://github.com/inutomo0123/dotfiles.git

    # 設定
    if [ -d ${HOME}/.emacs.d ]; then
	mv ${HOME}/.emacs.d ${HOME}/.emacs.d.org
    fi
    ln -s ${HOME}/repo.d/dotfiles/.emacs.d ${HOME}/
}


#step0
#step1
#setup-etckeeper
#setup-tmux
#setup-powerline
#setup-emacs
config-emacs
