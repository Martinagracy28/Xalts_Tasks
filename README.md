# Token Contract Deployment on Ethereum Sepolia Testnet

This repository contains the Solidity implementation of a customizable ERC20 token contract with whitelisting and blacklisting functionalities. The contract can be deployed on the Ethereum Sepolia Testnet using the Remix IDE.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Contract Overview](#contract-overview)
- [Deployment Steps](#deployment-steps)
- [Interacting with the Contract](#interacting-with-the-contract)
- [Events](#events)

## Prerequisites
1. **MetaMask Wallet**: Install the [MetaMask browser extension](https://metamask.io/) and set up a wallet.
2. **Testnet ETH**: Acquire some ETH on the Sepolia Testnet for transaction fees. You can get test ETH from [Sepolia Faucets](https://cloud.google.com/application/web3/faucet/ethereum/sepolia).
3. **Remix IDE**: Open the [Remix IDE](https://remix.ethereum.org/) in your web browser.

## Contract Overview
The `Token` contract implements the ERC20 standard and includes functionalities for:
- **Whitelisting** and **Blacklisting** wallets, managed exclusively by the contract owner.
- Normal users can transfer tokens only if their wallets are whitelisted.
- Tracking interactions between wallets.
- Minting an initial supply of tokens to the owner's wallet.

## Deployment Steps

1. **Open Remix IDE**: Go to [Remix IDE](https://remix.ethereum.org/).

2. **Create a New File**:
   - In the file explorer, create a new file named `Token.sol`.
   - Copy and paste the provided contract code [contracts folder](./SmartContracts/TokenContract.sol) into this file.

3. **Compile the Contract**:
   - Go to the "Solidity Compiler" tab (the second icon from the left).
   - Ensure the compiler version is set to `0.8.0` or a compatible version.
   - Click on the "Compile Token.sol" button.

4. **Configure MetaMask**:
   - Open your MetaMask wallet.
   - Switch to the **Ethereum Sepolia Testnet**:
     - Click on the network dropdown in MetaMask and select "Custom RPC" (or add a network if needed).
     - Enter the following details:
       - **Network Name**: Ethereum Sepolia Testnet
       - **New RPC URL**: `https://sepolia.infura.io/v3/`
       - **Chain ID**: `11155111`
       - **Symbol**: `ETH`
       - **Block Explorer URL**: `https://sepolia.etherscan.io`
     - Click "Save."
   - You can use [Infura](https://infura.io/) to get your `Infura Project ID`.

5. **Get Testnet ETH**:
   - Go to [Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) and enter your MetaMask wallet address to receive test ETH.
   - Make sure you have enough Sepolia ETH for deployment and gas fees.

6. **Deploy the Contract**:
   - In Remix, go to the "Deploy & Run Transactions" tab (the third icon).
   - Select "Injected Web3" as the Environment.
   - Ensure MetaMask is connected to the Sepolia Testnet and that you have sufficient test ETH for gas fees.
   - In the "Deploy" section, enter the initial owner's wallet address in the constructor input field (if required).
   - Click the "Deploy" button.
   - Confirm the transaction in MetaMask.

7. **Confirmation**:
   - Once the deployment is successful, you will see the contract address in the Remix terminal.

## Interacting with the Contract
After deploying the contract, you can interact with it directly from the Remix IDE. Here are the key functionalities:
- **Transfer Tokens**: Whitelisted users can transfer tokens to other whitelisted addresses.
- **Whitelisting Addresses**: The contract owner can add addresses to the whitelist.
- **Blacklisting Addresses**: The contract owner can remove addresses from the whitelist by adding them to the blacklist.

## Events
The contract emits the following events:
- `Whitelisted(address indexed account)`
- `Blacklisted(address indexed account)`
- `Transfer(address indexed from, address indexed to, uint256 value)`
