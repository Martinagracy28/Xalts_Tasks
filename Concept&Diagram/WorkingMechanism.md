# Smart Contract Whitelist/Blacklist Address Interaction

## Project Overview
This project tracks and manages interactions between Ethereum smart contracts and wallets (whitelist/blacklist). It uses **React.js** for off-chain processing and **Firebase** as the database to store interaction data. The main flow involves fetching on-chain events, storing them in Firebase, and then processing the data to identify addresses interacting with whitelist and blacklist wallets.

## Key Features:
- Interaction with Ethereum smart contracts (whitelist/blacklist).
- Fetch on-chain events using **JSON-RPC**.
- Store event data in **Firebase**.
- Retrieve and process stored data using **React.js**.
- Perform batch processing to identify addresses interacting with whitelist and blacklist wallets.

---

## Step-by-Step Flow

### 1. **Smart Contract (On-Chain)**

#### 1.1. Transfer Function
- The contract has a `Transfer` function that initiates a token transfer between wallets.
- Before processing the transfer, the contract checks if both the sender and receiver are **whitelisted**. If they are not, the transaction is terminated.
- If the transfer is valid, the transaction is processed, and an event is emitted to record the transfer (`Transfer event`).

#### 1.2. Blacklist/Whitelist Functions
- The contract has `Whitelist` and `Blacklist` functions that accept wallet addresses and update their status.
- Once an address is added to either list, the contract emits an event (`Whitelist/Blacklist event`) to notify the off-chain components.

### 2. **Off-Chain Processing (React.js & Firebase)**

#### 2.1. Fetch On-Chain Events
- **Ethereum Client API (JSON-RPC)** is used to fetch emitted events (Transfer, Whitelist, Blacklist) from the Ethereum blockchain.
  - The off-chain system listens for these events using Web3.js or Ethers.js and captures the address details.

#### 2.2. Store Data in Firebase
- The fetched event data (addresses, event type, timestamps) is then stored in a **Firebase Database** for later retrieval.
  - Firebase will have two main collections:
    - **whitelisted_addresses**: Stores all wallet addresses added to the whitelist.
    - **blacklisted_addresses**: Stores all wallet addresses added to the blacklist.

### 3. **Fetch and Process Data (React.js)**

#### 3.1. Fetch Data from Firebase
- Once the event data is stored in Firebase, it can be retrieved using **React.js**.
- Fetch all peers that have directly interacted with whitelist and blacklist wallets separately.

### 4. **Batch Processing with Web3.js for Transaction Optimization**

In this section, we leverage the **Web3.js** library to perform batch processing for transactions related to the whitelist and blacklist functions, specifically focusing on optimizing gas fees.

#### 4.1. Using Web3.js Batch Requests
**Web3.js** allows us to group multiple contract calls into a single transaction. This is particularly useful for optimizing gas fees, as it can reduce the overall cost by combining multiple actions into one.

- **Batch Requests**: We create a batch request that includes calls to the whitelist and blacklist functions in the smart contract. By doing this, we reduce the number of separate transactions sent to the Ethereum network, thereby minimizing gas costs.

#### 4.2. Cost Efficiency through Combined Transactions
- **Gas Optimization**: By batching the function calls, we not only save on gas fees but also improve the efficiency of our contract interactions. This is because each transaction incurs a base fee, and by grouping them, we can significantly reduce redundant costs.
- **Reducing Network Load**: Fewer transactions mean less congestion on the network, leading to faster confirmations and a lower likelihood of transaction failures due to network issues.

### 5. **Final Output**
- The processed data is outputted as two separate lists of unique wallet addresses that have interacted with the whitelist and blacklist addresses.
- This allows further analysis or actions on these addresses (e.g., reporting, additional processing).

