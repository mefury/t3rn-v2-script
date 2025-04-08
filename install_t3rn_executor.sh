#!/bin/bash

# t3rn Executor Installation Script
# This script automates the installation and setup of the t3rn executor on Linux

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Display credits
display_credits() {
    echo -e "\n${BOLD}${CYAN}"
    echo "  ████████╗██████╗ ██████╗ ███╗   ██╗"
    echo "  ╚══██╔══╝╚════██╗██╔══██╗████╗  ██║"
    echo "     ██║    █████╔╝██████╔╝██╔██╗ ██║"
    echo "     ██║    ╚═══██╗██╔══██╗██║╚██╗██║"
    echo "     ██║   ██████╔╝██║  ██║██║ ╚████║"
    echo "     ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝"
    echo -e "${NC}\n${BOLD}${PURPLE}       EXECUTOR SETUP SCRIPT${NC}\n"
    
    echo -e "${BOLD}Author:${NC}  MEFURY"
    echo -e "${BOLD}Twitter:${NC} https://x.com/meefury"
    echo -e "${BOLD}GitHub:${NC}  https://github.com/mefury/t3rn-v2-script\n"
    
    echo -e "This script will help you set up and run a t3rn executor node."
    echo -e "It will update your system, install dependencies, download the"
    echo -e "latest executor binary, and configure it with appropriate settings.\n"
}

# Display credits at the start
display_credits

# Function to display section headers
section() {
    echo -e "\n${BOLD}${GREEN}=== $1 ===${NC}"
}

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to display information messages
info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Function to check if command executed successfully
check_command() {
    if [ $? -ne 0 ]; then
        error_exit "$1"
    fi
}

# Function to get user confirmation
confirm() {
    read -p "$1 (y/n): " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to create environment file
create_env_file() {
    cat > "$1" <<EOL
# Environment settings for t3rn executor
export ENVIRONMENT=${ENVIRONMENT}
export LOG_LEVEL=${LOG_LEVEL}
export LOG_PRETTY=${LOG_PRETTY}
export EXECUTOR_PROCESS_BIDS_ENABLED=${EXECUTOR_PROCESS_BIDS_ENABLED}
export EXECUTOR_PROCESS_ORDERS_ENABLED=${EXECUTOR_PROCESS_ORDERS_ENABLED}
export EXECUTOR_PROCESS_CLAIMS_ENABLED=${EXECUTOR_PROCESS_CLAIMS_ENABLED}
export EXECUTOR_MAX_L3_GAS_PRICE=${EXECUTOR_MAX_L3_GAS_PRICE}
export PRIVATE_KEY_LOCAL=${PRIVATE_KEY_LOCAL}
export ENABLED_NETWORKS=${ENABLED_NETWORKS}
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=${EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API}
export RPC_ENDPOINTS='${RPC_ENDPOINTS}'
EOL
    chmod 600 "$1" # Set restrictive permissions for security
}

# Check if script is run as root
if [ "$(id -u)" -eq 0 ]; then
    info "Running as root. This is not recommended for security reasons."
    if ! confirm "Do you want to continue anyway?"; then
        exit 1
    fi
fi

# Check OS
section "System Check"
if [[ "$(uname)" != "Linux" ]]; then
    error_exit "This script is designed for Linux only"
fi

DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
info "Detected distribution: $DISTRO"

# Set directory for installation
INSTALL_DIR="${HOME}/t3rn"
info "Installation directory: $INSTALL_DIR"

# Clean up any existing installation
if [ -d "$INSTALL_DIR" ]; then
    section "Cleaning Up Previous Installation"
    info "Found existing t3rn directory at $INSTALL_DIR"
    
    if confirm "Do you want to remove the existing installation and start fresh?"; then
        info "Removing existing t3rn installation..."
        rm -rf "$INSTALL_DIR"
        check_command "Failed to remove existing installation"
        info "Previous installation removed successfully"
        
        # Recreate empty installation directory
        mkdir -p "$INSTALL_DIR"
        check_command "Failed to create installation directory"
    else
        error_exit "Installation aborted by user. Please backup or remove the existing installation manually."
    fi
else
    mkdir -p "$INSTALL_DIR"
    check_command "Failed to create installation directory"
fi

# Update and upgrade system
section "System Update"
info "Updating system packages..."
if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
    sudo apt-get update
    check_command "Failed to update package lists"
    
    if confirm "Do you want to upgrade all packages? This might take some time."; then
        sudo apt-get upgrade -y
        check_command "Failed to upgrade packages"
    fi
    
    # Install necessary packages
    section "Installing Dependencies"
    info "Installing required packages..."
    sudo apt-get install -y curl wget tar jq
    check_command "Failed to install required packages"
else
    info "Automatic update not available for your distribution. Please update your system manually."
    if ! confirm "Continue with installation without updating system?"; then
        exit 1
    fi
fi

# Download and install t3rn executor
section "Downloading t3rn Executor"
cd "$INSTALL_DIR" || error_exit "Failed to navigate to installation directory"

# Get release information
info "Fetching release information..."
RELEASES=$(curl -s "https://api.github.com/repos/t3rn/executor-release/releases?per_page=5")
check_command "Failed to fetch release information"

# Ask if user wants to use an older version
if confirm "Do you want to use an older version of the executor? (Default: No)"; then
    echo -e "\n${BOLD}Available versions:${NC}"
    # Display available versions
    echo "$RELEASES" | jq -r 'map(.tag_name) | to_entries | .[] | "\(.key + 1). \(.value)"'
    
    # Get user choice
    while true; do
        read -p "Choose version (1-5): " version_choice
        if [[ "$version_choice" =~ ^[1-5]$ ]]; then
            TAG_NAME=$(echo "$RELEASES" | jq -r ".[$((version_choice-1))].tag_name")
            break
        else
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 5.${NC}"
        fi
    done
else
    # Use latest version
    TAG_NAME=$(echo "$RELEASES" | jq -r '.[0].tag_name')
fi

info "Selected version: $TAG_NAME"

# Download binary
info "Downloading executor binary..."
DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/${TAG_NAME}/executor-linux-${TAG_NAME}.tar.gz"
wget "$DOWNLOAD_URL" -O "executor-linux-${TAG_NAME}.tar.gz"
check_command "Failed to download executor binary"

# Extract archive
info "Extracting executor binary..."
tar -xzf "executor-linux-${TAG_NAME}.tar.gz"
check_command "Failed to extract archive"

# Navigate to the executor binary location
EXECUTOR_BIN_DIR="$INSTALL_DIR/executor/executor/bin"
if [ ! -d "$EXECUTOR_BIN_DIR" ]; then
    error_exit "Binary directory not found. Extraction may have failed or directory structure is different."
fi

cd "$EXECUTOR_BIN_DIR" || error_exit "Failed to navigate to binary directory"
chmod +x executor
check_command "Failed to set execute permission on executor binary"

# Configure environment settings - only ask for essential values
section "Configuring Executor"

# Set default environment variables directly
export ENVIRONMENT="testnet"
export LOG_LEVEL="debug"
export LOG_PRETTY="false"
export EXECUTOR_PROCESS_BIDS_ENABLED="true"
export EXECUTOR_PROCESS_ORDERS_ENABLED="true"
export EXECUTOR_PROCESS_CLAIMS_ENABLED="true"
export ENABLED_NETWORKS="arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn"

# Ask for gas price
read -p "Max L3 gas price in gwei (default: 100): " EXECUTOR_MAX_L3_GAS_PRICE
EXECUTOR_MAX_L3_GAS_PRICE=${EXECUTOR_MAX_L3_GAS_PRICE:-100}
export EXECUTOR_MAX_L3_GAS_PRICE

# Ask for private key
PRIVATE_KEY_LOCAL=""
while [ -z "$PRIVATE_KEY_LOCAL" ]; do
    read -p "Private key (required): " PRIVATE_KEY_LOCAL
    if [ -z "$PRIVATE_KEY_LOCAL" ]; then
        echo -e "${RED}Private key is required${NC}"
    elif [[ ! $PRIVATE_KEY_LOCAL =~ ^[0-9a-fA-F]{64}$ ]]; then
        echo -e "${RED}Invalid private key format. It should be a 64-character hex string.${NC}"
        PRIVATE_KEY_LOCAL=""
    fi
done
export PRIVATE_KEY_LOCAL

# RPC Configuration
section "RPC Configuration"

# Default RPC endpoints
DEFAULT_RPC_ENDPOINTS='{
    "l2rn": ["https://t3rn-b2n.blockpi.network/v1/rpc/public", "https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "blst": ["https://sepolia.blast.io", "https://blast-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"],
    "mont": ["https://testnet-rpc.monad.xyz"]
}'

# Network names and descriptions
declare -A NETWORK_NAMES
NETWORK_NAMES=( 
    ["l2rn"]="t3rn Network"
    ["arbt"]="Arbitrum Sepolia"
    ["bast"]="Base Sepolia"
    ["blst"]="Blast Sepolia"
    ["opst"]="Optimism Sepolia"
    ["unit"]="Unichain Sepolia"
    ["mont"]="Monad Testnet"
)

# Ask user if they want to use custom RPC endpoints
USE_CUSTOM_RPC=false
if confirm "Do you want to use custom RPC endpoints? (Default: No)"; then
    USE_CUSTOM_RPC=true
    # Initialize JSON structure
    RPC_ENDPOINTS="{"
    
    # Get custom RPC for each network
    for network_code in l2rn arbt bast blst opst unit mont; do
        echo -e "\n${BOLD}${NETWORK_NAMES[$network_code]} (${network_code})${NC}"
        
        # Get primary RPC
        read -p "Enter primary RPC endpoint: " primary_rpc
        
        if [ -z "$primary_rpc" ]; then
            info "Using default RPC endpoint for ${NETWORK_NAMES[$network_code]}"
            # Extract default from the DEFAULT_RPC_ENDPOINTS
            primary_rpc=$(echo "$DEFAULT_RPC_ENDPOINTS" | jq -r ".[\"$network_code\"][0]")
        fi
        
        # Start array
        RPC_ENDPOINTS+="\"$network_code\": [\"$primary_rpc\""
        
        # Ask for secondary RPC (optional)
        read -p "Enter secondary RPC endpoint (optional, press Enter to skip): " secondary_rpc
        if [ ! -z "$secondary_rpc" ]; then
            RPC_ENDPOINTS+=", \"$secondary_rpc\""
        else
            # Use default secondary RPC if none provided
            secondary_rpc=$(echo "$DEFAULT_RPC_ENDPOINTS" | jq -r ".[\"$network_code\"][1]")
            if [ "$secondary_rpc" != "null" ]; then
                RPC_ENDPOINTS+=", \"$secondary_rpc\""
            fi
        fi
        
        # Close array
        RPC_ENDPOINTS+="]"
        
        # Add comma if not last item
        if [ "$network_code" != "mont" ]; then
            RPC_ENDPOINTS+=", "
        fi
    done
    
    # Close JSON structure
    RPC_ENDPOINTS+="}"
    
    echo -e "\n${BOLD}Custom RPC Configuration:${NC}"
    echo "$RPC_ENDPOINTS" | jq '.' || echo "$RPC_ENDPOINTS"
else
    info "Using default RPC endpoints"
    RPC_ENDPOINTS="$DEFAULT_RPC_ENDPOINTS"
fi

export RPC_ENDPOINTS

# Set API processing settings based on RPC choice
if [ "$USE_CUSTOM_RPC" = true ]; then
    info "Using custom RPCs: Disabling API processing"
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
else
    info "Using default RPCs: Enabling API processing"
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
fi

section "Starting Executor"
info "Starting t3rn executor with the configured settings..."
info "Auto-restart enabled: If the executor crashes, it will restart after 20 seconds"
info "Press Ctrl+C twice in quick succession to exit completely"

# Function to handle SIGINT (Ctrl+C)
trap_count=0
trap_time=0

trap ctrl_c INT

ctrl_c() {
    current_time=$(date +%s)
    
    if (( current_time - trap_time < 3 )); then
        ((trap_count++))
    else
        trap_count=1
    fi
    
    trap_time=$current_time
    
    if (( trap_count >= 2 )); then
        echo -e "\n${BOLD}${RED}Exiting t3rn executor...${NC}"
        exit 0
    else
        echo -e "\n${BOLD}${YELLOW}Press Ctrl+C again within 3 seconds to exit completely${NC}"
        return 1
    fi
}

# Start the executor with auto-restart
while true; do
    echo -e "\n${BOLD}${GREEN}Starting t3rn executor...${NC}"
    ./executor
    
    # If executor exits with any status
    echo -e "\n${BOLD}${YELLOW}Executor stopped. Restarting in 20 seconds...${NC}"
    echo -e "${YELLOW}Press Ctrl+C twice in quick succession to exit${NC}"
    
    # Wait for 20 seconds before restarting
    sleep 20
done

exit 0