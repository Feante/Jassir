#!/bin/bash
# reinstall_no_models.sh - Fast reinstall skipping model downloads

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================================${NC}"
echo -e "${BLUE}        JARVIS - FAST REINSTALL (SKIPPING MODELS)            ${NC}"
echo -e "${BLUE}==============================================================${NC}"
echo -e "This script will refresh your dependencies and app code."
echo ""

# Check if we are in the right directory
if [ ! -d "scr/scripts" ]; then
    echo -e "${RED}Error: Could not find 'scr/scripts' directory.${NC}"
    echo "Please run this script from the root of the jarvis repository."
    exit 1
fi

SCRIPT_DIR="scr/scripts"

run_step() {
    local script_name=$1
    local description=$2
    echo -e "\n${YELLOW}>>> Step: $description ($script_name)${NC}"
    if [ -f "$SCRIPT_DIR/$script_name" ]; then
        chmod +x "$SCRIPT_DIR/$script_name"
        bash "$SCRIPT_DIR/$script_name"
    else
        echo -e "${RED}Error: Script $script_name not found in $SCRIPT_DIR${NC}"
        exit 1
    fi
}

# 1. Dependencies
run_step "install_dependencies.sh" "Refreshing Dependencies & Venv"

# 2. Skip Models
echo -e "\n${BLUE}>>> Skipping Step: download_models.sh (Models preserved)${NC}"

# 3. Application Source
run_step "install_app.sh" "Redeploying Application Source Code"

# 4. Launcher
run_step "create_launcher.sh" "Refreshing Launchers"

# 5. Verification
run_step "verify_install.sh" "Verifying Installation"

echo -e "\n${GREEN}==============================================================${NC}"
echo -e "${GREEN}        FAST REINSTALL COMPLETE!                             ${NC}"
echo -e "${GREEN}==============================================================${NC}"
echo -e "Your models were preserved. You can start JARVIS with: ${BLUE}jassir${NC}"
echo ""
