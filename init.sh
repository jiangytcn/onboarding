#!/bin/bash

set -eu

set _platform=""
if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
    _platform="darwin"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    _platform="linux"
fi

install_rvm() {
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash
    rvm reload
}

install_kube() {
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$_platform/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl $HOME/bin/kubectl
    $HOME/bin/kubectl version --client
}

install_helm() {
 	curl -L https://git.io/get_helm.sh | bash
    $HOME/bin/helm version --client
}

install_jx() {
    if [ "$_platform" == 'linux' ]; then
        curl -L https://github.com/jenkins-x/jx/releases/download/v2.0.526/jx-$_platform-amd64.tar.gz | tar xzv
        chmod +x ./jx
        mv jx $HOME/bin
    else
        if ! hash jx 2>/dev/null; then
            brew tap jenkins-x/jx
            brew install jx
        fi
    fi

    jx version --no-verify=true -n
}

rm -rf ~/tmp/onboarding
mkdir -p ~/tmp/onboarding
[ ! -d $HOME/bin ] && $(mkdir -p $HOME/bin)
export PATH=$PATH:$HOME/bin
pushd ~/tmp/onboarding
install_rvm
install_kube
export HELM_INSTALL_DIR=$HOME/bin
install_helm
install_jx
popd ~/tmp/onboarding
rm -rf ~/tmp/onboarding
