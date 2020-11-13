#!/bin/bash

set -ue

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

SRC_DIR="${HOME}/local/src"
LOCAL_DIR="${HOME}/local"
BIN_DIR="${HOME}/local/bin"

SERIAL="$(date +%Y%m%d%H%M%S)"

TMUX_VERSION="3.1b"
EMACS_VERSION="27.1"

# tmux
function setup-tmux(){

    # 依存パッケージ
    sudo apt install -y \
         build-essential \
         libncurses5-dev \
         libevent-dev

    # ダウンロード
    mkdir -p "${SRC_DIR}"
    cd "${SRC_DIR}"
    curl -OL \
         "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
    tar -zxvf "tmux-${TMUX_VERSION}.tar.gz"

    # インストール
    cd "./tmux-${TMUX_VERSION}"
    ./configure --prefix="${LOCAL_DIR}"
    make
    make install

    # バックアップ
    if [ -f "${HOME}/.tmux.conf "]; then
        mv "${HOME}/.tmux.conf" "${HOME}/.tmux.conf.${SERIAL}"
    fi

    # 設定
    cd "${SCRIPT_DIR}"
    cp -i ./.tmux.conf "${HOME}/"

    # PATH
    cat <<EOF >> "${HOME}/.bashrc"

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

    # インストール先の取得
    location=$(pip3 show powerline-status \
                   | grep "Location" \
                   | grep -o -E "/.*$")

    # 設定
    cat <<EOF >> "${HOME}/.tmux.conf"

# powerline
run-shell "powerline-daemon -q"
source "${location}/powerline/bindings/tmux/powerline.conf"
EOF

    # PATH
    cat <<EOF >> "${HOME}/.bashrc"

# powerline
PATH="\${HOME}/.local/bin:\${PATH}"
EOF

}

# emacs
function setup-emacs(){

    # 依存パッケージ
    sudo apt install -y \
         build-essential \
         libncurses5-dev \
         libgnutls28-dev \
         pkg-config \
         mailutils

    # ダウンロード
    mkdir -p "${SRC_DIR}"
    cd "${SRC_DIR}"
    curl -OL \
         "http://gnu.mirrors.hoobly.com/emacs/emacs-${EMACS_VERSION}.tar.gz"
    tar -zxvf "emacs-${EMACS_VERSION}.tar.gz"

    # インストール
    cd "./emacs-${EMACS_VERSION}"
    ./configure --prefix="${LOCAL_DIR}" --without-x
    make
    make install

   # PATH
   cat <<EOF >> "${HOME}/.bashrc"

# emacs
PATH="\${HOME}/local/bin:\${PATH}"
EOF

}

function config-emacs(){

    # ダウンロード
    mkdir -p "${SRC_DIR}"
    cd "${SRC_DIR}"
    git clone "https://github.com/inutomo0123/dotfiles.git"

    # バックアップ
    if [ -d ${HOME}/.emacs.d ]; then
	    mv "${HOME}/.emacs.d" "${HOME}/.emacs.d.${SERIAL}"
    fi

    ln -s "${SRC_DIR}/dotfiles/.emacs.d" "${HOME}/.emacs.d"
}

function setup-font(){

    # ダウンロード
    mkdir -p "${SRC_DIR}"
    cd "${SRC_DIR}"
    git clone https://github.com/powerline/fonts.git

    # インストール
    cd fonts/
    ./install.sh
}

function setup-fish(){

    cd "${SCRIPT_DIR}"

    # インストール
    sudo apt-add-repository ppa:fish-shell/release-3
    sudo apt update
    sudo apt install -y fish

    # FISHER
    # 退避
    if [ -d "${HOME}/.local/share/omf/" ]; then
        mv "${HOME}/.local/share/omf/" "${HOME}/.local/share/omf.${SERIAL}"
    fi
    curl -L https://get.oh-my.fish | fish
    curl https://git.io/fisher --create-dirs \
         -sLo "${HOME}/.config/fish/functions/fisher.fish"
    fish --command="fisher install oh-my-fish/theme-bobthefish"

    # 行末の日付を非表示にする
    cat <<EOF >> "${HOME}/.config/fish/config.fish"

# 行末の日付時刻を非表示にする
set -U theme_display_date no
set -U theme_display_cmd_duration no
EOF

    # tmux
    cat <<EOF >> "${HOME}/.tmux.conf"

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
