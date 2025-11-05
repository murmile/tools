#!/bin/bash

### Author: lk ###

### REQUIREMENTS ####
# 1. Have Spotify Account
# 2. Install Zotify (also requires python and ffmpeg)
# 3. Launch script from shell and follow prompt

if ! command -v zotify &> /dev/null; then
    echo "Cannot run this, Zotify is not installed"
    echo "Quitting..."
    exit 1
fi
if ! command -v ffmpeg &> /dev/null; then
    echo "Cannot run this, ffmpeg is not installed"
    echo "Quitting..."
    exit 1
fi

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

SCRIPT_DIR=$(dirname "$0")
touch "${SCRIPT_DIR}/zotify_quickie.log"

clear
echo ""
echo "####################################################"
echo "################## Zotify Quickie ##################"
echo "####################################################"
echo ""

read -p "Paste Spotify link (song, album, playlist, ...): " SPOTIFY_URL

while true; do

    echo ""
    curl -s "$SPOTIFY_URL" | awk -F'<title>|</title>' '{print $2}' | head -n 1 | awk -F'|' '{print $1}'
    echo -n "Downloading..."
    TITLES=$(zotify "$SPOTIFY_URL" --download-quality "very_high" 2>&1 | tee -a "/Users/luk/scripts/zotify_quickie/zotify_quickie.log" | grep -i "Skipping lyrics" | awk -F 'lyrics for |: lyrics' '{print $2}')
    echo " Done."
    echo "$TITLES" | while read -r title; do
        if find "$HOME/Music/Zotify Music" -type f -name "*$title*" -print -quit | grep -q .; then
            FILEPATH=$(find "$HOME/Music/Zotify Music" -type f -name "*$title*" | sed "s|^\./|$HOME/Music/Zotify Music|")
            echo -e "${GREEN}SUCCESS:${RESET} $FILEPATH"
        else
            echo -e "${RED}FAILED:${RESET} $title NOT downloaded. Bad link? Internet connection? Zotify config missing?"
        fi
    done
    echo ""
    echo "##### Downloaded to $HOME/Music/Zotify Music/"
    echo "##### Format: .ogg Vorbis (320kbps)"
    echo "####################################################"
    echo ""

    sleep 2

    read -p "Paste another Spotify link (song, album, playlist, ...): " SPOTIFY_URL

done