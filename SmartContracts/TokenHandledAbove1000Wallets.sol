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
    
    // Events for logging wallet status changes
    event Whitelisted(address indexed account);
    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);

    // Custom event for tracking transfers with additional logging
    event TransferLogged(address indexed from, address indexed to, uint256 amount);

    // Hardcoded wallet addresses that will be initialized as whitelisted
    address[5] public initialWallets = [
        0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c, // Wallet 1
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C, // Wallet 2
        0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB, // Wallet 3
        0x583031D1113aD414F02576BD6afaBfb302140225, // Wallet 4
        0xdD870fA1b7C4700F2BD7f44238821C26f7392148  // Wallet 5
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

    // Function to whitelist multiple accounts at once
    function whitelist(address[] calldata _accounts) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            address account = _accounts[i];
            require(walletStatus[account] == WalletStatus.Blacklisted, "Account is not blacklisted");
            walletStatus[account] = WalletStatus.Whitelisted; // Set wallet status to whitelisted

            emit Whitelisted(account); // Emit event for each whitelisted account
        }
    }

    // Function to blacklist multiple accounts at once
    function blacklist(address[] calldata _accounts) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            address account = _accounts[i];
            require(walletStatus[account] == WalletStatus.Whitelisted, "Account is already blacklisted");
            walletStatus[account] = WalletStatus.Blacklisted; // Set wallet status to blacklisted

            emit Blacklisted(account); // Emit event for each blacklisted account
        }
    }

    // Overriding the transfer function to include whitelist and blacklist checks
    function transfer(address recipient, uint256 amount) public override onlyWhitelisted notBlacklisted(recipient) returns (bool) {
        
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
