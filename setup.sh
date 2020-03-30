#!/bin/bash

set -ue

SCRIPT_DIR=$(cd $(dirname $0); pwd)
WORK_DIR="/tmp/$(date +%Y%m%d%H%M%S)"

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
    cd ${SCRIPT_DIR}
    cp -i ./.tmux.conf ${HOME}/

    # PATH
    cat <<EOF >> ${HOME}/.bashrc

# tmux
PATH="\${HOME}/local/bin:\${PATH}"
EOF

}

# powerline/powerline
function setup-powerline(){

    # 依存パッケージ
    sudo apt install -y python3-pip

    # インストール
    pip3 install --user powerline-status

    # 設定
    cat <<EOF >> ${HOME}/.tmux.conf

# powerline
run-shell "powerline-daemon -q"
source "${HOME}/.local/lib/python3.6/site-packages/powerline/bindings/tmux/powerline.conf"
EOF

    # PATH
    cat <<EOF >> ${HOME}/.bashrc

# powerline
PATH="\${HOME}/.local/bin:\${PATH}"
EOF

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

function setup-font(){

    # ダウンロード
    mkdir -p ${HOME}/repo.d
    cd ${HOME}/repo.d/
    git clone https://github.com/powerline/fonts.git

    # インストール
    cd fonts/
    ./install.sh
}


function setup-fish(){

    cd ${SCRIPT_DIR}

    # インストール
    sudo apt-add-repository ppa:fish-shell/release-3
    sudo apt update
    sudo apt install -y fish

    # FISHER
    curl -L https://get.oh-my.fish | fish
    curl https://git.io/fisher --create-dirs \
         -sLo ${HOME}/.config/fish/functions/fisher.fish
    fish --command="fisher add oh-my-fish/theme-bobthefish"

    # tmux
    cat <<EOF >> ${HOME}/.tmux.conf

# デフォルトシェル
set -g default-command /usr/bin/fish
set -g default-shell /usr/bin/fish
EOF

}

setup-tmux
setup-powerline
setup-emacs
config-emacs
setup-font
setup-fish
