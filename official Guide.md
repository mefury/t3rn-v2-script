# T3RN EXECUTOR SETUP GUIDE

## Introduction

Welcome to the t3rn Executor Setup! The t3rn Executor is a node that processes bids, orders, and claims across multiple blockchain networks. This guide provides step-by-step instructions to set up and run your own executor.

## System Requirements

- Operating System: Ubuntu (recommended) or macOS
- Storage: Minimum 10GB available disk space
- Memory: Minimum 4GB RAM
- Network: Stable internet connection

## Installation

### 1. Download Executor Binary

Download the executable (tar.gz) from the official repository:
- [Latest Releases](https://github.com/t3rn/executor-release/releases/)

Optional: Verify the download integrity by comparing the SHA256 checksum with the provided sha256sum file.

### 2. Installation Steps

#### For Ubuntu:
```bash
# Create and navigate to t3rn directory
mkdir t3rn
cd t3rn

# Download latest release
curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")' | \
xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz

# Extract the archive
tar -xzf executor-linux-*.tar.gz

# Navigate to the executor binary location
cd executor/executor/bin
```

#### For macOS:
```bash
# Create and navigate to t3rn directory
mkdir t3rn
cd t3rn

# Download latest release
curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -o '"tag_name": "[^"]*' | \
cut -d'"' -f4 | \
xargs -I {} curl -LO https://github.com/t3rn/executor-release/releases/download/{}/executor-macos-{}.tar.gz

# Extract the archive
tar -xzf executor-macos-*.tar.gz

# Navigate to the executor binary location
cd executor/executor/bin
```

## Configuration

To configure the Executor, you'll need to set several environment variables. Copy and paste each command into your terminal, adjusting the values as needed.

### 1. General Settings

```bash
# Set your preferred Node Environment
export ENVIRONMENT=testnet

# Configure logging
export LOG_LEVEL=debug
export LOG_PRETTY=false

# Enable processing of bids, orders, and claims
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true

# Set maximum gas price limit (in gwei, default: 1000)
export EXECUTOR_MAX_L3_GAS_PRICE=100
```

#### Understanding Process Settings:
- `EXECUTOR_PROCESS_BIDS_ENABLED=false`: Stops processing orders you've been bidding on (30-minute pickup window remains)
- `EXECUTOR_PROCESS_ORDERS_ENABLED=false`: Stops processing new orders
- `EXECUTOR_PROCESS_CLAIMS_ENABLED=false`: Stops processing claims

### 2. Wallet Configuration

```bash
# Set your wallet's private key (IMPORTANT: Use your own key, not this example)
export PRIVATE_KEY_LOCAL=dead93c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56dbeef
```

⚠️ **Security Note**: Keep your private key secure. Never share it or commit it to version control.

### 3. Network Configuration

```bash
# Enable networks to operate on
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn'

# Configure custom RPC endpoints (optional)
export RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
}'

# API processing configuration
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
```

#### Network Information:
- If your wallet balance falls below the threshold on an enabled network, that network will be automatically removed
- For a complete list of supported networks, visit: [Supported network names](#) (link missing in original guide)
- You can find reliable RPC URLs for EVM networks on [ChainList](https://chainlist.org/)

## Running the Executor

### Basic Start
```bash
./executor
```

### Running in Background

#### Option 1: Using Screen (Recommended for Beginners)
```bash
# Install screen (Ubuntu)
sudo apt-get install screen

# Create and start a new screen session
screen -S t3rn-executor

# Start the executor in the screen session
./executor

# To detach: Press Ctrl + A, then D
# To reattach: screen -r t3rn-executor
```

#### Option 2: Using tmux (Modern Alternative)
```bash
# Install tmux (Ubuntu)
sudo apt-get install tmux

# Create and start new session
tmux new -s t3rn-executor

# Start the executor in the tmux session
./executor

# To detach: Press Ctrl + B, then D
# To reattach: tmux attach -t t3rn-executor
```

#### Option 3: Using systemd (Ubuntu Only)
For a permanent solution that starts automatically on boot, create a systemd service:

```bash
# Create a systemd service file
sudo nano /etc/systemd/system/t3rn-executor.service
```

Add the following content (adjust paths and user as needed):
```
[Unit]
Description=T3RN Executor Service
After=network.target

[Service]
Type=simple
User=<your-username>
WorkingDirectory=/path/to/t3rn/executor/executor/bin
ExecStart=/path/to/t3rn/executor/executor/bin/executor
Restart=on-failure
RestartSec=10
Environment="ENVIRONMENT=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="EXECUTOR_PROCESS_BIDS_ENABLED=true"
Environment="EXECUTOR_PROCESS_ORDERS_ENABLED=true"
Environment="EXECUTOR_PROCESS_CLAIMS_ENABLED=true"
Environment="EXECUTOR_MAX_L3_GAS_PRICE=100"
Environment="PRIVATE_KEY_LOCAL=your-private-key-here"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn"
Environment="EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true"

[Install]
WantedBy=multi-user.target
```

Then enable and start the service:
```bash
sudo systemctl enable t3rn-executor.service
sudo systemctl start t3rn-executor.service
sudo systemctl status t3rn-executor.service
```

## Getting Testnet Tokens

To bid on transaction orders on testnet, you need BRN tokens. Visit the [Faucet](#) (link missing in original guide) to obtain test tokens.

## Verification & Troubleshooting

### Verify Executor Is Running Correctly:
- Check terminal output for error messages
- Monitor logs using the configured log level
- Verify network connections to enabled networks

### Common Issues and Solutions:

1. **Executor Fails to Start**
   - Verify all environment variables are set correctly
   - Ensure your private key is valid
   - Check that the executor binary has execute permissions (`chmod +x executor`)

2. **Network Connectivity Issues**
   - Verify your internet connection
   - Check that the RPC endpoints are accessible
   - Try using alternative RPC endpoints

3. **Insufficient Balance**
   - Ensure you have sufficient BRN token balance in your wallet for each network
   - Visit the faucet to get more test tokens if needed

## Additional Resources

- [Official Documentation](#)
- [Discord Community](#)
- [GitHub Repository](https://github.com/t3rn/executor-release)

## Glossary

- **Executor**: A node in the t3rn network that processes cross-chain transactions
- **Bid**: An offer to execute a transaction on behalf of a user
- **Order**: A transaction waiting to be executed
- **Claim**: A request for payment after successful execution
- **RPC (Remote Procedure Call)**: Endpoints used to interact with blockchain networks