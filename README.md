# T3RN Executor Setup Script

This repository contains an automated setup script for the t3rn Executor, a node that processes bids, orders, and claims across multiple blockchain networks.

## Quick Start

Run the following command to download and execute the installation script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mefury/t3rn-v2-script/main/install_t3rn_executor.sh)"
```

## About T3RN Executor

The t3rn Executor is a node that processes cross-chain transactions in the t3rn network. By running an executor, you can:

- Process bids, orders, and claims across multiple blockchain networks
- Earn rewards for successfully executing transactions
- Contribute to the decentralization of the t3rn network

## System Requirements

- Operating System: Ubuntu (recommended) or other Linux distributions
- Storage: Minimum 10GB available disk space
- Memory: Minimum 4GB RAM
- Network: Stable internet connection

## Manual Installation Steps

If you prefer to install the executor manually:

1. Clone this repository:
   ```bash
   git clone https://github.com/mefury/t3rn-v2-script.git
   cd t3rn-v2-script
   ```

2. Make the script executable:
   ```bash
   chmod +x install_t3rn_executor.sh
   ```

3. Run the installation script:
   ```bash
   ./install_t3rn_executor.sh
   ```

## Running in Background (Screen)

The script itself doesn't include screen functionality, but you can run it in a screen session:

1. Install screen if you don't have it:
   ```bash
   sudo apt-get install screen
   ```

2. Create a new screen session:
   ```bash
   screen -S t3rn-executor
   ```

3. Run the installation command inside the screen session:
   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/mefury/t3rn-v2-script/main/install_t3rn_executor.sh)"
   ```

4. Detach from the screen session (keep it running in background):
   - Press `Ctrl + A`, then `D`

5. To reattach to the screen session later:
   ```bash
   screen -r t3rn-executor
   ```

6. To list all running screen sessions:
   ```bash
   screen -ls
   ```

7. To kill a screen session:
   ```bash
   screen -X -S t3rn-executor quit
   ```

## Script Features

The installation script automates the following tasks:

- System update and installation of dependencies
- Download of the latest t3rn executor binary
- Configuration of environment variables
- Setting up and starting the executor
- Clean removal of previous installations (if any)

## Configuration

The script asks for the following inputs:

1. **Gas Price**: Maximum gas price in gwei (default: 100)
2. **Private Key**: Your wallet's private key (required)
3. **RPC Endpoints**: Choose between default RPCs or set custom endpoints for each chain

### Custom RPC Configuration

The script allows you to configure custom RPC endpoints for each supported network:

- **t3rn Network** (l2rn)
- **Arbitrum Sepolia** (arbt)
- **Base Sepolia** (bast)
- **Optimism Sepolia** (opst)
- **Unichain Sepolia** (unit)

For each network, you can specify:
- A primary RPC endpoint (required)
- A secondary RPC endpoint (optional, for fallback)

If you leave any endpoint blank, the script will use the default RPC for that network.

## Important Notes

- **Security**: The script requires your private key for operation. Always review scripts before running them, especially those handling sensitive information.
- **Updates**: Check this repository regularly for updates to the script.
- **Testnet Tokens**: You'll need BRN tokens to operate on the testnet. Visit the faucet (link to be provided) to obtain test tokens.

## Troubleshooting

If you encounter issues:

1. **Executor Fails to Start**
   - Verify environment variables are set correctly
   - Ensure your private key is valid
   - Check that the executor binary has execute permissions

2. **Network Connectivity Issues**
   - Verify your internet connection
   - Check that the RPC endpoints are accessible

3. **Insufficient Balance**
   - Ensure you have sufficient BRN token balance in your wallet for each network

## Additional Resources

- [Official T3RN Documentation](https://docs.t3rn.io/)
- [T3RN GitHub Repository](https://github.com/t3rn/executor-release)
- [Report Issues](https://github.com/mefury/t3rn-v2-script/issues)

## License

This script is provided under the MIT License.

## Disclaimer

This is an unofficial installation script. Please use at your own risk. 