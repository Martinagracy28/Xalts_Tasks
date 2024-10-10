// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

// Importing the ERC20 token standard implementation from OpenZeppelin's contracts library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Importing the Ownable contract from OpenZeppelin, which provides basic authorization control functions
import "@openzeppelin/contracts/access/Ownable.sol";

// Defining the main contract 'Token' which inherits from ERC20 and Ownable
contract Token is ERC20, Ownable {
    // Define the possible states for a wallet
    enum WalletStatus { Blacklisted, Whitelisted }

    // Mapping to track the wallet status (blacklisted or whitelisted)
    mapping(address => WalletStatus) public walletStatus;
    
    // Mapping to track peers each address interacted with
    mapping(address => address[]) public interactedPeers; 

    // Events for logging wallet status changes
    event Whitelisted(address indexed account);
    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);

    // Custom event for tracking transfers with additional logging
    event TransferLogged(address indexed from, address indexed to, uint256 amount);

    // Hardcoded wallet addresses that will be initialized as whitelisted
    address[5] public initialWallets = [
        0xd72558AB56489747360657ab4802176Ce18B49E5, // Wallet 1
        0xdc61dE4fED82E2CDbC5E31156c4dA41389Ae1e22, // Wallet 2
        0xA7FFa83C165A13625B2F1676651b1dED562e42F9, // Wallet 3
        0x7a9CC1337D476EbD45b67220D79DF615c5A0C509, // Wallet 4
        0x13f273412e7591e3259ed528CBda3a6FB524CF10  // Wallet 5
    ];

    // Constructor to initialize the token, owner, and initial whitelisted wallets
    constructor(address initialOwner) ERC20("MyToken", "MTK") Ownable(msg.sender){
        transferOwnership(initialOwner); // Set the initial owner of the contract to `initialOwner`
        
        // Whitelist all hardcoded wallets
        for (uint256 i = 0; i < initialWallets.length; i++) {
            walletStatus[initialWallets[i]] = WalletStatus.Whitelisted; // Set wallet status to whitelisted
            emit Whitelisted(initialWallets[i]); // Emit event for each whitelisted wallet
        }
        
        walletStatus[msg.sender] = WalletStatus.Whitelisted; // Whitelist the owner's wallet
        
        _mint(msg.sender, 10000 * 10 ** decimals()); // Mint initial supply of tokens to the owner's wallet
    }

    // Modifier to ensure that only whitelisted addresses can call certain functions
    modifier onlyWhitelisted() {
        require(walletStatus[msg.sender] == WalletStatus.Whitelisted, "Sender is not whitelisted");
        _;
    }

    // Modifier to prevent transfers to blacklisted addresses
    modifier notBlacklisted(address _address) {
        require(walletStatus[_address] == WalletStatus.Whitelisted, "Receiver wallet is blacklisted");
        _;
    }

    // Function to whitelist an account that is currently blacklisted, can only be called by the owner
    function whitelist(address _account) external onlyOwner {
        require(walletStatus[_account] == WalletStatus.Blacklisted, "Account is not blacklisted");
        walletStatus[_account] = WalletStatus.Whitelisted; // Set wallet status to whitelisted
        
        // Re-whitelist peers that were blacklisted due to interaction with this account
        for (uint256 i = 0; i < interactedPeers[_account].length; i++) {
            address peer = interactedPeers[_account][i];
            if (walletStatus[peer] == WalletStatus.Blacklisted) {
                walletStatus[peer] = WalletStatus.Whitelisted; // Set peer status to whitelisted
                emit Whitelisted(peer); // Emit event for whitelisted peer
            }
        }

        emit Whitelisted(_account);
    }

    // Function to blacklist a whitelisted account, can only be called by the owner
    function blacklist(address _account) external onlyOwner {
        require(walletStatus[_account] == WalletStatus.Whitelisted, "Account is already blacklisted");
        walletStatus[_account] = WalletStatus.Blacklisted; // Set wallet status to blacklisted

        // Blacklist peers that interacted with this account
        for (uint256 i = 0; i < interactedPeers[_account].length; i++) {
            address peer = interactedPeers[_account][i];
            if (walletStatus[peer] == WalletStatus.Whitelisted) {
                walletStatus[peer] = WalletStatus.Blacklisted; // Set peer status to blacklisted
                emit Blacklisted(peer); // Emit event for blacklisted peer
            }
        }

        emit Blacklisted(_account);
    }

    // Overriding the transfer function to include whitelist and blacklist checks
    function transfer(address recipient, uint256 amount) public override onlyWhitelisted notBlacklisted(recipient) returns (bool) {
        // Track interactions between sender and recipient
        interactedPeers[msg.sender].push(recipient);
        interactedPeers[recipient].push(msg.sender);
        
        // Emit the custom transfer logging event
        emit TransferLogged(msg.sender, recipient, amount);

        return super.transfer(recipient, amount); // Execute the actual transfer
    }

    // Hook that is called before any token transfer, including minting and burning
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        // Check if sender and recipient are whitelisted
        require(walletStatus[from] == WalletStatus.Whitelisted || msg.sender == owner(), "Sender is blacklisted");
        require(walletStatus[to] == WalletStatus.Whitelisted, "Recipient is blacklisted");
        
        super._beforeTokenTransfer(from, to, amount); // Call the parent hook
    }
}
