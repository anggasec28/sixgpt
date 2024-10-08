#!/bin/bash

curl -s https://raw.githubusercontent.com/anggasec28/logo/refs/heads/main/logo.sh | bash
sleep 6

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[0;36m'

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL} "
            ;;
    esac
}

check_docker_installed() {
    if command -v docker >/dev/null 2>&1; then
        show "Docker sudsh terinstall"
        return 0
    else
        return 1
    fi
}

install_docker() {
    show "Sedang menginstall Docker..." "progress"
    source <(wget -O - https://raw.githubusercontent.com/anggasec28/modul/refs/heads/main/docker.sh)
}

mkdir sixgpt
cd sixgpt

prompt_user_input() {
    read -p "Masukkan Private Key ( Jangan gunakan wallet utama ): " VANA_PRIVATE_KEY
    read -p "Masukkan nama jaringan Vana (satori): " VANA_NETWORK
}

clear_ram_cache() {
    show "Membersihkan RAM cache..." "proses"
    sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
    show "RAM sukses dibersihkan!"
}

run_docker_containers() {
    sudo docker volume create ollama && \
    sudo docker run -d --name ollama \
      -p 11439:11434 \
      -v ollama:/root/.ollama \
      --restart unless-stopped \
      ollama/ollama:0.3.12 && \
    sudo docker run -d --name sixgpt3 \
      -p 3210:3000 \
      --link ollama \
      -e VANA_PRIVATE_KEY="$VANA_PRIVATE_KEY" \
      -e VANA_NETWORK="$VANA_NETWORK" \
      --restart no \
      sixgpt/miner:latest
}

if ! check_docker_installed; then
    install_docker
fi

prompt_user_input

clear_ram_cache

show "Docker containers berjalan..." "memproses"
run_docker_containers
echo
show "Kalian bisa jalankan pre mining juga di Telegram MiniApps : https://t.me/VanaDataHeroBot/VanaDataHero?startapp=1673790707"
echo
