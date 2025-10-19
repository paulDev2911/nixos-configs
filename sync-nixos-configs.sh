#!/usr/bin/env bash

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verzeichnisse
SOURCE_DIR="$HOME/nixos-configs"
TARGET_DIR="/etc/nixos"

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  NixOS Config Sync Script${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""

# Prüfe ob Source-Verzeichnis existiert
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}✗ Fehler: $SOURCE_DIR existiert nicht!${NC}"
    exit 1
fi

# Prüfe ob Target-Verzeichnis existiert
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}✗ Fehler: $TARGET_DIR existiert nicht!${NC}"
    exit 1
fi

echo -e "${YELLOW}Source:${NC} $SOURCE_DIR"
echo -e "${YELLOW}Target:${NC} $TARGET_DIR"
echo ""

# Kopiere alle Dateien und Verzeichnisse
echo -e "${YELLOW}➜ Kopiere Dateien...${NC}"

sudo rsync -av \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='*.swp' \
    --exclude='*~' \
    --exclude='hardware-configuration.nix' \
    "$SOURCE_DIR/" "$TARGET_DIR/"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Dateien erfolgreich kopiert!${NC}"
    echo ""
    
    # Frage ob System neu gebaut werden soll
    read -p "NixOS neu bauen? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}➜ Baue NixOS System...${NC}"
        sudo nixos-rebuild switch
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ System erfolgreich neu gebaut!${NC}"
        else
            echo ""
            echo -e "${RED}✗ Fehler beim Systemaufbau!${NC}"
            exit 1
        fi
    fi
else
    echo ""
    echo -e "${RED}✗ Fehler beim Kopieren!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Fertig!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"