#!/usr/bin/env bash

RED='\u001b[31m'
GREEN='\e[92m'
YELLOW='\u001b[33m'
RESET='\033[0m \n'

function show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Builds and deploys a Docker infrastructure for Selenium tests."
  echo "Options:"
  echo "  -h, --help      Display this help message."
  echo "  -s, --skip-net  Skip network creation if it already exists."
  echo ""
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

if ! command -v docker &> /dev/null; then
  echo -e "${RED}ERROR: Docker not found.${RESET}"
  exit 1
fi

if ! command -v docker-compose &> /dev/null; then
  echo -e "${RED}ERROR: Docker Compose not found.${RESET}"
  exit 1
fi

if [[ "$1" == "-s" || "$1" == "--skip-net" ]]; then
  SKIP_NETWORK=1
else
  SKIP_NETWORK=0
fi

echo -e "${YELLOW}Preparing build...${RESET}"
APP_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )" && cd "$APP_PATH"/../ || exit

if [[ $SKIP_NETWORK -eq 0 ]]; then
  echo -e "${YELLOW}Creating required network...${RESET}"
  docker network create selenoid || true
fi

echo -e "${YELLOW}Downloading required webdrivers...${RESET}"
docker pull selenoid/chrome:latest
docker pull selenoid/firefox:latest
docker pull selenoid/video-recorder:latest-release

echo -e "${YELLOW}Starting infrastructure via docker-compose...${RESET}"
if ! docker-compose up -d --force-recreate --build --remove-orphans; then
    echo -e "${RED}ERROR: Failed to start infrastructure.${RESET}"
    exit 1
fi

echo -e "${GREEN}Build successful.${RESET}"
