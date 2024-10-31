/*******************************************************************************
 *
 * Copyright (c) 2021 Modenero Corp.
 * Released under the MIT License.
 * SPDX-License-Identifier: MIT
 * 
 *
 * TelrWallet - AmTrust (First Edition)
 * 
 *              ----------------------------------------------------------------
 * 
 *              !!! WARNING WARNING WARNING !!!
 *              !!! THIS IS HIGHLY EXPERIMENTAL SOFTWARE !!!
 *              !!! USE AT YOUR OWN RISK !!!
 *             
 *              ----------------------------------------------------------------
 *             
 *              Our team at Modenero has been hard at work over the Crypto Winter;
 *              and we're very excited to announce the premier release of a still
 *              experimental, but really fun and social new way to "Do Crypto!"
 * 
 *              TL;DR
 *              -----
 * 
 *              A meta-currency / smart wallet built for the purpose of promoting 
 *              and supporting the core economic needs of the Bitcoin community:
 *                  1. Electronic Commerce
 *                  2. Website Monetization
 *                  3. Wealth Management
 * 
 *              ALL transactions are guaranteed by Solidty contracts managed by a 
 *              growing community of federated nodes.
 * 
 *              For more information, please visit: 
 *              https://telr.io/wallet
 *
 * Version 21.11.17
 *
 * https://modenero.com
 * support@modenero.com
 */

pragma solidity ^0.8.0;

/* Import libraries. */
import '../../libs/SafeMath.sol';

/*******************************************************************************
 *
 * ECRecovery
 *
 * Contract function to validate signature of pre-approved token transfers.
 * (borrowed from LavaWallet)
 */
interface ECRecovery {
    function recover(bytes32 hash, bytes calldata sig) external pure returns (address);
}


/*******************************************************************************
 *
 * ERC Token Standard #20 Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/*******************************************************************************
 *
 * ApproveAndCallFallBack
 *
 * Contract function to receive approval and execute function in one call
 * (borrowed from MiniMeToken)
 */
interface ApproveAndCallFallBack {
    function approveAndCall(address spender, uint tokens, bytes calldata data) external;
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}


/*******************************************************************************
 *
 * ERC-721 Non-Fungible Token Interface
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
interface ERC721Interface {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}


/*******************************************************************************
 *
 * Owned contract
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);
    }
}


/*******************************************************************************
 * 
 * ModeneroDb Interface
 */
interface ModeneroDbInterface {
    /* Interface getters. */
    function getAddress(bytes32 _key) external view returns (address);
    function getBool(bytes32 _key)    external view returns (bool);
    function getBytes(bytes32 _key)   external view returns (bytes calldata);
    function getInt(bytes32 _key)     external view returns (int);
    function getString(bytes32 _key)  external view returns (string calldata);
    function getUint(bytes32 _key)    external view returns (uint);

    /* Interface setters. */
    function setAddress(bytes32 _key, address _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setBytes(bytes32 _key, bytes calldata _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setString(bytes32 _key, string calldata _value) external;
    function setUint(bytes32 _key, uint _value) external;

    /* Interface deletes. */
    function deleteAddress(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
}


/*******************************************************************************
 *
 * Wrapped ETH (WETH) Interface
 */
interface WETHInterface {
    receive() external payable;
    function deposit() external payable ;
    function withdraw(uint wad) external;
    function totalSupply() external view returns (uint);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);
}


/*******************************************************************************
 *
 * ERC-165 Interface
 */
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


/*******************************************************************************
 *
 * ERC-1155 Interface
 */
// TODO Add interface functions
//      (see https://github.com/enjin/erc-1155/blob/master/contracts/IERC1155.sol)
//      (and https://blog.enjincoin.io/erc-1155-the-crypto-item-standard-ac9cf1c5a226)


/*******************************************************************************
 *
 * TelrWallet IS THE "OFFICIAL" META-CURRENCY OF THE GROWING COMMUNITY
 * OF TELR-SPONSORED PRODUCTS AND SERVICES.
 *
 * In conjunction with the Telr Wallet Daemon, this contract manages the
 * ability to dynamically allocate the assets of a "smart" crypto wallet,
 * in real-time, based on a user's pre-selected financial profile.
 *
 * Initial support for the following cryptos:
 *     - Ethereum (WETH)   : HODL as a long-term growth investment.
 *     - MakerDAO (DAI)    : SPEDN on digital goods and services.
 *     - Bai (BAI)  : STAKE to access premium features and services.
 */
contract TelrWallet is Owned {
    using SafeMath for uint;

    /* Initialize predecessor contract. */
    address payable private _predecessor;

    /* Initialize successor contract. */
    address payable private _successor;
    
    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Modenero Db contract. */
    ModeneroDbInterface private _modeneroDb;

    /* Set namespace. */
    // NOTE: Use of `namespace` is REQUIRED when generating ANY & ALL
    //       ModeneroDb keys; in order to prevent ANY accidental or
    //       malicious SQL-injection vulnerabilities / attacks.
    string private _namespace = 'telr.wallet';

    /* Initialize account balances. */
    mapping(address => mapping (address => uint)) private _balances;

    /* Initialize expired signature flags. */
    mapping(bytes32 => bool) private _expiredSignatures;
    
    /* Initialize revision depth. */
    // NOTE: Allows for balance and transaction aggregation
    //       from legacy Telr Wallet contract instance(s).
    // FIXME Determine the MAXIMUM depth and set here.
    //       Estimated to be between 10-20
    uint private _MAX_REVISION_DEPTH = 10;
    
    event Deposit(
        address indexed token, 
        address owner, 
        uint tokens,
        bytes data
    );

    event Migrate(
        address indexed token, 
        address owner, 
        uint tokens
    );

    event Skipped(
        address token,
        address sender, 
        address receiver, 
        uint tokens
    );

    event Transfer(
        address indexed token, 
        address sender, 
        address receiver, 
        uint tokens
    );

    event Withdraw(
        address indexed token, 
        address owner, 
        uint tokens
    );
    
    /***************************************************************************
     *
     * Constructor
     */
    constructor() {
        /* Initialize ModeneroDb (eternal) storage database contract. */
        // NOTE We hard-code the address here, since it should never change.
        // _modeneroDb = ModeneroDbInterface(0x68133E0A4996D0103c2135dcD8E2084450DF66D5);
        _modeneroDb = ModeneroDbInterface(0xeba5dE9BcF9fa0a749C9F870408B5c4D3C8a6fF5); // AMBER

        /* Initialize (aname) hash. */
        bytes32 hash = keccak256(abi.encodePacked('aname.', _namespace));

        /* Set predecessor address. */
        _predecessor = payable(_modeneroDb.getAddress(hash));

        /* Verify predecessor address. */
        if (_predecessor != address(0)) {
            /* Retrieve the last revision number (if available). */
            uint lastRevision = TelrWallet(_predecessor).getRevision();
            
            /* Set (current) revision number. */
            _revision = lastRevision + 1;
        }
    }

    /**
     * @dev Only allow access to an authorized Modenero administrator.
     */
    modifier onlyAuthBy0Admin() {
        /* Verify write access is only permitted to authorized accounts. */
        require(_modeneroDb.getBool(keccak256(
            abi.encodePacked(msg.sender, '.has.auth.for.', _namespace))) == true);

        _;      // function code is inserted here
    }

    /**
     * Fallback (default)
     * 
     * Accepts direct ETH transfers to be wrapped for owner into one of the
     * canonical Wrapped ETH (WETH) contracts:
     *     - Mainnet: 0x0
     *     - Amber: 0x0
     * 
     * NOTE: We are forced to hard-code all possible network contract
     *       (addresses) into this fallback since the WETH contract 
     *       DOES NOT provide enough gas for us to lookup the 
     *       specific address for our network.
     * 
     * NOTE: This contract requires ~50k gas to wrap ETH using the 
     *       fallback/wrap functions. However, it will require ~80k 
     *       to initialize on first-use.
     */
    receive () external payable {
        /* Initialize WETH contract flag. */
        bool isWethContract = false;
        
        /* Initialize WETH contracts array. */
        address[4] memory contracts;
        
        /* Set Mainnet. */
        contracts[0] = address(0);

        /* Set Amber. */
        contracts[1] = address(0);

        /* Loop through all network contracts. */
        for (uint i = 0; i < contracts.length; i++) {
            /* Validate sender. */
            if (msg.sender == contracts[i]) {
                /* Set flag. */
                isWethContract = true;
            }
        }

        /* DO NOT (re-)wrap incoming ETH from Wrapped ETH contract. */
        if (!isWethContract) {
            _wrap(msg.sender);
        }
    }


    /***************************************************************************
     * 
     * ACTIONS
     * 
     */

    /**
     * Wrap
     */
    function wrap() external payable returns (
        bool success,
        bytes memory data
    ) {
        /* Return wrap success. */
        return _wrap(msg.sender);
    }
    
    /**
     * Wrap
     * 
     * NOTE: This function is primarily used to support instance 
     *       migration(s) of WETH.
     */
    function wrap(
        address payable _owner
    ) external payable returns (
        bool success,
        bytes memory data
    ) {
        return _wrap(_owner);
    }

    /**
     * Wrap
     * 
     * Send Ether into this method. It gets wrapped and then deposited 
     * in this contract as a token balance assigned to the sender.
     */
    function _wrap(
        address _owner
    ) private returns (
        bool success, 
        bytes memory data
    ) {
        /* Set WETH address. */
        address wethAddress = address(_weth());

        /* Forward this payable ether into the wrapping contract. */
        // NOTE: Transfer ETH before balance credit to prevent re-entry attack.
        (success, data) = wethAddress.call
            {
                gas: 200000, 
                value: msg.value
            } 
            (abi.encodeWithSignature("deposit()"));
            
        /* Validate transfer. */
        if (success) {
            /* Increase WETH balance by sent value. */
            _balances[wethAddress][_owner] = 
                _balances[wethAddress][_owner].add(msg.value);
            
            /* Broadcast event. */
            emit Deposit(
                wethAddress, 
                _owner, 
                msg.value, 
                data
            );
        } else {
            /* Report error. */
            revert('An error occurred while wrapping your ETH.');
        }
    }

    /**
     * Unwrap
     */
    function unwrap(
        uint _tokens
    ) public returns (
        bool success,
        bytes memory data
    ) {
        return _unwrap(payable(msg.sender), _tokens);
    }

    /**
     * Unwrap
     * 
     * We allow administrative unwrapping of WETH held
     * in the ZeroCache, FOR COMPLIANCE PURPOSES ONLY.
     * 
     * NOTE: This function is reserved for exclusive use by
     *       Zer0net Administration ONLY.
     * 
     *       Tokens unwrapped by an administrator can
     *       ONLY be transferred to the ORIGINAL owner.
     */
    function unwrap(
        address payable _owner, 
        uint _tokens
    ) onlyAuthBy0Admin external returns (
        bool success,
        bytes memory data
    ) {
        return _unwrap(_owner, _tokens);
    }

    /**
     * Unwrap
     * 
     * Allows an owner to unwrap their Ether from the 
     * canonical WETH contract.
     */
    function _unwrap(
        address payable _owner, 
        uint _tokens
    ) private returns (
        bool success,
        bytes memory data
    ) {
        /* Set WETH address. */
        address wethAddress = address(_weth());

        /* Validate balance. */
        if (_balances[wethAddress][_owner] < _tokens) {
            revert('Oops! You DO NOT have enough WETH.');
        }

        /* Decrease WETH balance by sent value. */
        // NOTE: Decrease balance before transfer to prevent re-entry attack.
        _balances[wethAddress][_owner] = 
            _balances[wethAddress][_owner].sub(_tokens);

        /* Withdraw ETH from Wrapper contract. */
        (success, data) = wethAddress.call
            {
                gas: 200000
            }
            (abi.encodeWithSignature("withdraw(uint256)", _tokens));

        /* Validate withdrawal. */
        if (success) {
            /* Transfer "unwrapped" Ether (ETH) back to owner. */
            _owner.transfer(_tokens);
    
            /* Broadcast event. */
            emit Withdraw(
                wethAddress,
                _owner,
                _tokens
            );
        } else {
            /* Report error. */
            revert('An error occurred while unwrapping your ETH.');
        }
    }
    

    /***************************************************************************
     * 
     * ACTIONS
     * 
     */

    /**
     * Deposit
     * 
     * Provides support for "pre-approved" token deposits.
     * 
     * NOTE: Required pre-allowance/approval is required in order
     *       to successfully complete the transfer.
     */
    function deposit(
        address _token, 
        address _from, 
        uint _tokens, 
        bytes calldata _data
    ) external returns (bool success) {
        /* Make deposit. */
        return _deposit(_token, _from, _tokens, _data);
    }

    /**
     * Receive Approval
     * 
     * Will typically be called from `approveAndCall`.
     * 
     * NOTE: Owner can assign ANY address to receive the deposit 
     *       (including their own). By default, owner will be used.
     */
    function receiveApproval(
        address _from, 
        uint _tokens, 
        address _token, 
        bytes calldata _data
    ) public returns (bool success) {
        /* Make deposit. */
        return _deposit(_token, _from, _tokens, _data);
    }

    /**
     * Deposit
     * 
     * Deposits ANY ERC20-compatible token into this contract;
     * to be managed by Telr Wallet. 
     * 
     * NOTE: Owners maintain *100% control of their token(s) 
     *       at all times.
     * 
     * Administrators AT ANY TIME have the ability to return tokens
     * back to their ORIGINAL owners EOA (externally owned account) 
     * (https://ethereum.org/en/whitepaper/#ethereum-accounts)
     * 
     * THIS USE IS RESERVED FOR COMPLIANCE PURPOSES ONLY
     */
    function _deposit(
        address _token,
        address _from, 
        uint _tokens,
        bytes calldata _data
    ) private returns (bool success) {
        /* Transfer the ERC-20 tokens into Cache. */
        // NOTE: Transfer tokens before credit to prevent re-entry attack.
        ERC20Interface(_token).transferFrom(
            _from, address(this), _tokens);
        
        /* Initialize receiver (address). */
        address receiver = address(0);
        
        /**
         * If `_data` is an `address`, then set the value to `receiver`.
         * e.g. when `approveAndCall` is made from a contract 
         * (representing the owner).
         */
        if (_data.length == 20) {
            /* Retrieve the receiver's address from `data` payload. */
            receiver = _bytesToAddress(_data);
        } else {
            /* Set receiver to `from` (also the token owner). */
            receiver = _from;
        }

        /* Increase receiver balance. */
        _balances[_token][receiver] = 
            _balances[_token][receiver].add(_tokens);

        /* Broadcast event. */
        emit Deposit(_token, receiver, _tokens, _data);

        /* Return success. */
        return true;
    }

    /**
     * Withdraw
     */
    function withdraw(
        address _token, 
        uint _tokens
    ) public returns (bool success) {
        return _withdraw(msg.sender, _token, _tokens);
    }
    
    /**
     * Withdraw
     * 
     * We allow administrative withdrawls of tokens held
     * in the Telr Wallet, FOR COMPLIANCE PURPOSES ONLY.
     * 
     * NOTE: This function is reserved for exclusive use by
     *       Modenero Administration ONLY.
     * 
     *       Tokens withdrawn by an administrator can
     *       ONLY be transferred to the ORIGINAL owner.
     */
    function withdraw(
        address _owner, 
        address _tokenid, 
        uint _amount
    ) onlyAuthBy0Admin external returns (bool success) {
        return _withdraw(_owner, _tokenid, _amount);
    }

    /**
     * Withdraw
     * 
     * Allows the withdrawl of tokens held in the Telr Wallet
     * back to the ORIGINAL owner.
     */
    function _withdraw(
        address _owner, 
        address _tokenid, 
        uint _amount
    ) private returns (bool success) {
        /* Validate balance. */
        if (_balances[_tokenid][_owner] < _amount) {
            revert('Oops! You DO NOT have enough tokens.');
        }

        /* Decrease owner balance by token amount. */
        // NOTE: Decrease balance before transfer to prevent re-entry attack.
        _balances[_tokenid][_owner] = 
            _balances[_tokenid][_owner].sub(_amount);

        /* Transfer requested tokens to owner. */
        ERC20Interface(_tokenid).transfer(_owner, _amount);

        /* Broadcast event. */
        emit Withdraw(_tokenid, _owner, _amount);
    
        /* Return success. */
        return true;
    }

    /**
     * Transfer
     *
     * Transfers the "specified" ERC-20 tokens held by the sender
     * to the receiver's account.
     */
    function transfer(
        address _tokenid,
        address _to,
        uint _amount
    ) external returns (bool success) {
        return _transfer(
            _tokenid, 
            msg.sender, 
            _to, 
            _amount
        );
    }

    /**
     * (Relayed) Transfer
     * 
     * This transfer requires an off-chain (EC) signature, from the 
     * account holder, detailing the transaction.
     * 
     * Gas Station
     * -----------
     * 
     * Users may choose to boost the speed of execution for their 
     * transfer request, decreasing the delivery time to near instant 
     * (highest priority for miners to process) confirmation. 
     * 
     * A stake of Bai is required to be added to the request, 
     * in an amount specified by your preferred stakeholder.
     * 
     * This stake is 100% optional, as Standard Delivery will be 
     * FREE FOREVER!
     * 
     * TODO: Let's implement GasToken to provide stakeholders an opportunity
     *       to hedge against the volatility of future gas prices.
     *       (source: https://gastoken.io/)
     */
    function transfer(
        address _tokenid,             // contract address
        address _from,              // sender's address
        address _to,                // receiver's address
        uint _amount,               // quantity of tokens
        uint _expires,              // expiration time
        uint _nonce,                // unique integer
        bytes calldata _signature   // signed message
    ) external returns (bool success) {
        /* Calculate transfer hash. */
        bytes32 transferHash = keccak256(abi.encodePacked(
            address(this), 
            _tokenid, 
            _from,
            _to,
            _amount,
            _expires,
            _nonce
        ));

        /* Validate request has authorized signature. */
        bool requestHasAuthSig = _requestHasAuthSig(
            _from,
            transferHash,
            _expires,
            _signature
        );
        
        /* Validate authorization. */
        if (!requestHasAuthSig) {
            revert('Oops! This relay request is NOT valid.');
        }
        
        /* Request token transfer. */
        return _transfer(
            _tokenid, 
            _from, 
            _to, 
            _amount
        );
    }

    /**
     * Transfer
     *
     * Transfers the "specified" ERC-20 token(s) held by the sender
     * to the receiver's account.
     */
    function _transfer(
        address _tokenid,
        address _from,
        address _to,
        uint _amount
    ) private returns (bool success) {
        /* Validate balance. */
        if (_balances[_tokenid][_from] < _amount) {
            revert('Oops! You DO NOT have enough tokens.');
        }

        /* Remove the transfer value from sender's balance. */
        // NOTE: We decrease balance before adding to prevent re-entry attack.
        _balances[_tokenid][_from] = _balances[_tokenid][_from].sub(_amount);

        /* Add the transfer value to the receiver's balance. */
        _balances[_tokenid][_to] = _balances[_tokenid][_to].add(_amount);

        /* Broadcast event. */
        emit Transfer(
            _tokenid, 
            _from, 
            _to, 
            _amount
        );

        /* Return success. */
        return true;
    }
    
    /**
     * Multi Transfer
     *
     * Transfers multiple ERC-20 tokens held by the sender
     * to multiple receiver accounts.
     */
    function multiTransfer(
        address[] calldata _token,
        address[] calldata _to,
        uint[] calldata _amounts
    ) external returns (bool success) {
        return _multiTransfer(_token, msg.sender, _to, _amounts);
    }
    
    //----------------------------------------------------------------
    //----------------------------------------------------------------
    // NOTE: We DO NOT yet offer support for RELAYED Multi Transfers.
    //----------------------------------------------------------------
    //----------------------------------------------------------------

    /**
     * Transfer Multiple Tokens (w/ Single Transaction)
     * 
     * WARNING: Sending to multiple receipients is very risky,
     *          as there is NO way to control the gas costs per
     *          transaction (ie. contract addresses are limitless).
     * 
     *          For this reason, we SKIP ALL transfers to contract
     *          addresses. You can monitor the `Skipped` event.
     */
    function _multiTransfer(
        address[] calldata _token,
        address _from,
        address[] calldata _to,
        uint[] calldata _amounts
    ) private returns (bool success) {
        /* Loop through all receivers. */
        for (uint i = 0; i < _to.length; i++) {
            /* Set token. */
            address token = _token[i];
           
            /* Set receiver. */
            address to = _to[i];
            
            /* Set token amounts. */
            uint amounts = _amounts[i];
           
            /* Validate receiver address. */
            if (_ownerIsContract(to)) {
                /* Broadcast event. */
                emit Skipped(token, _from, to, amounts);
            } else {
                /* Transfer tokens. */
                _transfer(
                    token, _from, to, amounts);
            }
        }
        
        /* Return success. */
        return true;
    }

    /**
     * Cancel
     *
     * Cancels a previously authorized/signed transfer request, 
     * by invalidating the signature on-chain.
     */
    function cancel(
        address _token,       // Telr Wallet (contract) address
        address _from,        // sender's address
        address _to,          // receiver's address
        uint _amount,         // quantity of tokens
        uint _expires,        // expiration time
        uint _nonce,          // unique integer
        bytes calldata _signature      // signed message
    ) external returns (bool success) {
        /* Calculate cancel hash. */
        bytes32 cancelHash = keccak256(abi.encodePacked(
            address(this), 
            _token, 
            _from,
            _to,
            _amount,
            _expires,
            _nonce
        ));

        /* Validate request has authorized signature. */
        bool requestHasAuthSig = _requestHasAuthSig(
            _from,
            cancelHash,
            _expires,
            _signature
        );
        
        /* Validate authorization. */
        if (!requestHasAuthSig) {
            revert('Oops! This cancel request is NOT valid.');
        }
        
        /* Return success. */
        return true;
    }

    /**
     * Migrate
     */
    function migrate(
        address[] calldata _amount
    ) external returns (
        bool success,
        bytes memory data
    ) {
        return _migrate(msg.sender, _amount);
    }
    
    /**
     * Migrate
     * 
     * THIS FUNCTION IS UN-IMPLMENTED
     * 
     * NOTE: There is no ADMIN migration function available
     *       as a protection against UNAUTHORIZED transfer(s) to 
     *       possible rogue instance(s) of Telr Wallet.
     */

    /**
     * Migrate
     * 
     * Allows for the full balance transfer of a multiple token(s)
     * from legacy instance(s) to the LATEST instance of Telr Wallet.
     */
    function _migrate(
        address _owner, 
        address[] calldata _tokens
    ) private returns (
        bool success,
        bytes memory data
    ) {
        /* Set hash. */
        bytes32 hash = keccak256('aname.zerocache');

        /* Retrieve value from Modenero Db. */
        address latestWallet = _modeneroDb.getAddress(hash);

        /* Loop through all tokens. */
        for (uint i = 0; i < _tokens.length; i++) {
            /* Set token. */
            address token = _tokens[i];
            
            /* Retrieve balance. */
            // NOTE: Explicitly set depth to `0`, to retrieve the
            //       balance for ONLY this instance.
            uint balance = balanceOf(token, _owner, 0);
            
            /* Decrease owner balance to ZERO. */
            // NOTE: Balance is ZEROED here to prevent re-entry attack.
            _balances[token][_owner] = 0;

            /* Validate WETH contract (requires `unwrap`). */
            if (token == address(_weth())) {
                /* Set WETH address. */
                address wethAddress = address(_weth());
        
                /* Withdraw ETH from Wrapper contract. */
                (success, data) = wethAddress.call
                {
                    gas: 100000
                }
                (abi.encodeWithSignature("withdraw(uint256)", balance));
        
                /* (Re-)Wrap ETH into LATEST instance. */
                // NOTE: ETH will be wrapped on `_owner` behalf.
                (success, data) = latestWallet.call
                {
                    gas: 100000,
                    value: balance
                }
                (abi.encodeWithSignature("wrap(address)", _owner));
            } else {
                /* Set data to owner (address). */
                // NOTE: Required to assign tokens after being received
                //       by the new contract instance.
                bytes memory ownerAddress = abi.encodePacked(_owner);

                /* (Re-)Deposit tokens into LATEST instance. */
                // NOTE: Tokens will be credited to `_owner` (aka `data`).
                ApproveAndCallFallBack(token)
                    .approveAndCall(latestWallet, balance, ownerAddress);

                /* Set success. */
                success = true;
            }

            /* Broadcast event. */
            emit Migrate(token, _owner, balance);
        }
    }
    

    /***************************************************************************
     * 
     * GETTERS
     * 
     */

    /**
     * Get the token balance for account `tokenOwner`
     */
    function balanceOf(
        address _token,
        address _owner
    ) external view returns (uint balance) {
        /* Return balance. */
        return balanceOf(
            _token, _owner, _MAX_REVISION_DEPTH);
    }

    /**
     * Get the token balance for account `tokenOwner`
     * 
     * NOTE: Supports a virtually unlimited depth, 
     *       limited ONLY by the supplied gas amount.
     */
    function balanceOf(
        address _token,
        address _owner,
        uint _depth
    ) public view returns (uint balance) {
        /* Retrieve (current) balance. */
        balance = _balances[_token][_owner];
        
        /* Initialize legacy instance (to current predecessor). */
        address payable legacyInstance = getPredecessor();
        
        /* Validate legacy instance. */
        if (legacyInstance != address(0)) {
            /* Initialize total legacy balance. */
            uint totalLegacyBalance = 0;
            
            /* Loop through legacy instances for balance. */
            for (uint i = 0; i < _depth; i++) {
                /* Retrieve balance. */
                uint legacyBalance = TelrWallet(legacyInstance)
                    .balanceOf(_token, _owner);
                    
                /* Add to legacy balance total. */
                totalLegacyBalance = totalLegacyBalance.add(legacyBalance);
    
                /* Set the next legacy instance / predecessor (if available). */
                legacyInstance = TelrWallet(legacyInstance).getPredecessor();
                
                /* Validate legacy instance. */
                if (legacyInstance == address(0)) {
                    /* Break the loop. */
                    break;
                }
            }
            
            /* Add total legacy balance. */
            balance = balance.add(totalLegacyBalance);
        }
    }

    /**
     * Get Revision (Number)
     */
    function getRevision() public view returns (uint) {
        return _revision;
    }
    
    /**
     * Get Predecessor (Address)
     */
    function getPredecessor() public view returns (address payable) {
        return _predecessor;
    }
    
    /**
     * Get Successor (Address)
     */
    function getSuccessor() public view returns (address payable) {
        return _successor;
    }
    
    
    /***************************************************************************
     * 
     * SETTERS
     * 
     */

    /**
     * Set Successor
     * 
     * This is the contract address that replaced this current instnace.
     */
    function setSuccessor(
        address payable _newSuccessor
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Set successor contract. */
        _successor = _newSuccessor;
        
        /* Return success. */
        return true;
    }


    /***************************************************************************
     * 
     * INTERFACES
     * 
     */

    /**
     * Supports Interface (EIP-165)
     * 
     * (see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)
     * 
     * NOTE: Must support the following conditions:
     *       1. (true) when interfaceID is 0x01ffc9a7 (EIP165 interface)
     *       2. (false) when interfaceID is 0xffffffff
     *       3. (true) for any other interfaceID this contract implements
     *       4. (false) for any other interfaceID
     */
    function supportsInterface(
        bytes4 _interfaceID
    ) external pure returns (bool) {
        /* Initialize constants. */
        bytes4 InvalidId = 0xffffffff;
        bytes4 ERC165Id = 0x01ffc9a7;

        /* Validate condition #2. */
        if (_interfaceID == InvalidId) {
            return false;
        }

        /* Validate condition #1. */
        if (_interfaceID == ERC165Id) {
            return true;
        }
        
        // TODO Add additional interfaces here.
        
        /* Return false (for condition #4). */
        return false;
    }

    /**
     * ECRecovery Interface
     */
    function _ecRecovery() private view returns (
        ECRecovery ecrecovery
    ) {
        /* Initailze hash. */
        bytes32 hash = keccak256('aname.ecrecovery');
        
        /* Retrieve value from Modenero Db. */
        address aname = _modeneroDb.getAddress(hash);
        
        /* Initialize interface. */
        ecrecovery = ECRecovery(aname);
    }

    /**
     * Wrapped Ether (WETH) Interface
     * 
     * Retrieves the current WETH interface,
     * using the aname record from ModeneroDb.
     */
    function _weth() private view returns (
        WETHInterface weth
    ) {
        /* Initailze hash. */
        // NOTE: ERC tokens are case-sensitive.
        bytes32 hash = keccak256('aname.WETH');
        
        /* Retrieve value from Modenero Db. */
        address payable aname = payable(_modeneroDb.getAddress(hash));
        
        /* Initialize interface. */
        weth = WETHInterface(aname);
    }

    /**
     * MakerDAO DAI Interface
     * 
     * Retrieves the current DAI interface,
     * using the aname record from ModeneroDb.
     */
    function _dai() private view returns (
        ERC20Interface dai
    ) {
        /* Initailze hash. */
        // NOTE: ERC tokens are case-sensitive.
        bytes32 hash = keccak256('aname.DAI');
        
        /* Retrieve value from Modenero Db. */
        address aname = _modeneroDb.getAddress(hash);
        
        /* Initialize interface. */
        dai = ERC20Interface(aname);
    }

    /**
     * Bai Interface
     * 
     * Retrieves the current Bai interface,
     * using the aname record from ModeneroDb.
     */
    function _bai() private view returns (
        ERC20Interface bai
    ) {
        /* Initailze hash. */
        // NOTE: ERC tokens are case-sensitive.
        bytes32 hash = keccak256('aname.BAI');
        
        /* Retrieve value from Modenero Db. */
        address aname = _modeneroDb.getAddress(hash);
        
        /* Initialize interface. */
        bai = ERC20Interface(aname);
    }


    /***************************************************************************
     * 
     * UTILITIES
     * 
     */

    /**
     * Request Hash Authorized Signature
     * 
     * Validates ALL signature requests by:
     *     1. Uses ECRecovery to validate the signature.
     *     2. Verify expiration against the current block number.
     *     3. Sets a flag to block re-use of signature.
     */
    function _requestHasAuthSig(
        address _from,
        bytes32 _authHash,
        uint _expires,
        bytes calldata _signature
    ) private returns (bool success) {
        /* Calculate signature hash. */
        bytes32 sigHash = keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32', _authHash));

        /* Validate signature expiration. */
        if (_expiredSignatures[sigHash]) {
            return false;
        }

        /* Set expiration flag. */
        // NOTE: Set a flag here to prevent double-spending.
        _expiredSignatures[sigHash] = true;
        
        /* Validate the expiration time. */
        if (block.number > _expires) {
            return false;
        }
        
        /* Retrieve the authorized account (address). */
        address authorizedSigner = 
            _ecRecovery().recover(sigHash, _signature);

        /* Validate the requester matches the owner of the original signature. */
        if (_from != authorizedSigner) {
            return false;
        }

        /* Return success. */    
        return true;
    }

    /**
     * Is (Owner) Contract
     * 
     * Tests if a specified account / address is a contract.
     */
    function _ownerIsContract(
        address _owner
    ) private view returns (bool isContract) {
        /* Initialize code length. */
        uint codeLength;

        /* Run assembly. */
        assembly {
            /* Retrieve the size of the code on target address. */
            codeLength := extcodesize(_owner)
        }
        
        /* Set test result. */
        isContract = (codeLength > 0);
    }

    /**
     * Bytes-to-Address
     * 
     * Converts bytes into type address.
     */
    // function _bytesToAddress(
    //     bytes calldata _address
    // ) private pure returns (address) {
    //     uint160 m = 0;
    //     uint160 b = 0;

    //     for (uint8 i = 0; i < 20; i++) {
    //         m *= 256;
    //         b = uint160(_address[i]);
    //         m += (b);
    //     }

    //     return address(m);
    // }
    function _bytesToAddress(
        bytes memory _bytes
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(_bytes, 20))
        } 
    }
}
