#!/bin/bash

# Terminal colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color
VERSION="1.0.0"
IFACE='wg0'

info()
{
    echo ""
    echo -e "${YELLOW}Wireguard Setup (v${VERSION})"
    echo -e "${YELLOW}Copyright © 2022:${NC} Fernando Porrino Serrano"
    echo -e "${YELLOW}Under the AGPL license:${NC} https://github.com/FherStk/wireguard-setup/blob/main/LICENSE"
}

abort()
{
  #Source: https://stackoverflow.com/a/22224317    
  echo ""
  echo -e "${RED}An error occurred. Exiting...${NC}" >&2
  exit 1
}

apt_req()
{
  echo ""
  if [ $(dpkg-query -W -f='${Status}' ${1} 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then    
    echo -e "${LCYAN}Installing requirements: ${CYAN}${1}${NC}"
    apt install -y ${1};    
  else 
    echo -e "${CYAN}Requirement ${LCYAN}${1}${CYAN} already satisfied, skipping...${NC}"
  fi
}

wg_iface()
{
  echo ""
  if [ $(wg | grep ${IFACE}) -eq 0 ];
  then            
      echo -e "${LCYAN}Creating the ${LCYAN}${IFACE}${CYAN} interface:"
      ip link add dev wg0 type wireguard
      ip a | grep ${IFACE}            
  else 
    echo -e "${CYAN}Interface ${LCYAN}${IFACE}${CYAN} already exists, skipping...${NC}"
  fi
}

wg_setup()
{
    echo ""
    echo -e "${LCYAN}Setting up the ${LCYAN}${IFACE}${CYAN} interface:"
    
    echo "    Please, provide the listen-port:"
    read PORT

    echo "    Please, provide the current host's private-key:"
    read PRIVATE

    echo "    Please, provide the peer's public-key:"
    read PUBLIC

    echo "    Please, provide the allowed range of IPs (example: 10.0.99.0/24):"
    read NETWORK

    echo "    Please, provide the current host within the IP range (example: 27, which means 10.0.99.27/24):"
    read ID

    #TODO: split the NETWORK and change the last number for ID
    #https://unix.stackexchange.com/a/329085
    wg set wg0 listen-port $PORT private-key $PRIVATE peer $PUBLIC allowed-ips $NETWORK endpoint 209.202.254.14:$PORT
}

trap 'abort' 0
set -e

info
apt_req wireguard-tools
wg_iface
wg_setup

trap : 0
echo ""
echo -e "${GREEN}Done!${NC}" 