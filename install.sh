#!/bin/bash
sudo apt install -y build-essential
#### install docker
if !( which docker >/dev/null 2>/dev/null );then
  curl -fsSL get.docker.com | sudo sh
  sudo usermod -aG docker $(whoami)
fi

if !( which go >/dev/null 2>/dev/null );then
  [ -e go1.15.linux-amd64.tar.gz ] ||  wget https://golang.org/dl/go1.15.linux-amd64.tar.gz
  [ -e /usr/local/go ] || sudo tar -C /usr/local -xvf go1.15.linux-amd64.tar.gz

  if [ -z "$(cat ~/.bashrc | grep GOPATH)" ]; then
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"' >> ~/.bashrc
    export GOPATH=$HOME/go
    export PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"
  fi
fi

if ! [ -e /etc/docker/daemon.json ];then
  cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "runtimes" : {
    "runu-dev" : {
      "path" : "$GOPATH/bin/runu",
      "runtimeArgs" : []
    }
}
}
EOF
fi

go build
go install
sudo systemctl restart docker
