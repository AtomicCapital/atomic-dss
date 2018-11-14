pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./RegulatorService.sol";

contract AtomicDSS is ERC20, Ownable {
    byte public constant SUCCESS_CODE = hex"01";
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    RegulatorService public regulator;
    
    string public name;
    string public symbol;
    uint8 public decimals;

  /**
   * @notice Event triggered when `RegulatorService` contract is replaced
   */
    event ReplaceRegulator(address oldRegulator, address newRegulator);

  /**
   * @notice Modifier that calls `verify` method in `RegulatorService` contract
   * @dev Checks for restrictions logic and requires that none exist for a given transfer
   * @param _from The address of the sender
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   */
    modifier notRestricted (address _from, address _to, uint256 _value) {
        byte restrictionCode = regulator.verify(this, msg.sender, _from, _to, _value);
        require(restrictionCode == SUCCESS_CODE, regulator.restrictionMessage(restrictionCode));
        _;
    }

  /**
   * @dev Validate contract address
   * Credit: https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol#L107-L114
   * @param _addr The address of a smart contract
   */
    modifier isContract (address _addr) {
        uint length;
        assembly { length := extcodesize(_addr) }
        require(length > 0);
        _;
    }

  /**
   * @notice Constructor
   * @param _regulator Address of `RegulatorService` contract
   * @param _wallets List of addresses participating in the initial issuance
   * @param _amounts Amount of tokens to be minted for corresponding addresses
   */
    constructor(RegulatorService _regulator, address[] _wallets, uint256[] _amounts) public {
        regulator = _regulator;
        symbol = "ATOM";
        name = "Atomic Token";
        decimals = 18;

        // Setting up initial token distribution
        // for (uint256 i = 0; i < _wallets.length; i++){
        //     mint(_wallets[i], _amounts[i]);
        //     if(i == 10){
        //         break;
        //     }
        // }
    }

  /**
   * @notice Replaces the address pointer to the `RegulatorService`
   * @dev This method can only be called by the contract's owner
   * @param _regulator The address of the new `RegulatorService`
   */
    function replaceRegulator(RegulatorService _regulator) 
        public 
        onlyOwner 
        isContract(_regulator) 
    {
        address oldRegulator = regulator;
        regulator = _regulator;
        emit ReplaceRegulator(oldRegulator, regulator);
    }

  /**
   * @notice Overriden ERC20 transfer function with additional modifier to check for trade restrictions
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   * @return `true` if successful and `false` if unsuccessful
   */
    function transfer(address _to, uint256 _value)
        public
        notRestricted(msg.sender, _to, _value)
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

  /**
   * @notice Overriden ERC20 transferFrom function with additional modifier to check for trade restrictions
   * @param _from The address of the sender
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   * @return `true` if successful and `false` if unsuccessful
   */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        notRestricted(_from, _to, _value)
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

  /**
   * @notice Function that mints an amount of the token and assigns it to an account
   * @dev This method can only be called by the contract's owner
   * @param _account The account that will receive the created tokens
   * @param _amount The amount that will be created
   * @return `true` if successful and `false` if unsuccessful
   */
    function mint(address _account, uint256 _amount) 
        public
        onlyOwner
    {
        super._mint(_account, _amount);
    }

  /**
   * @notice Function that burns an amount of the token of from a given account
   * @dev This method can only be called by the contract's owner
   * @param _account The account whose tokens will be burnt
   * @param _amount The amount that will be burnt
   * @return `true` if successful and `false` if unsuccessful
   */
    function burn(address _account, uint256 _amount) 
        public
        onlyOwner
    {
        super._burn(_account, _amount);
    }

   /**
    * @dev Internal function that forces a token transfer from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
    function _forceTransfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_value <= _balances[_from]);
        require(_to != address(0));

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function forceTransfer(address _from, address _to, uint256 _value)
        public
        onlyOwner
        returns (bool)
    {
        return _forceTransfer(_from, _to, _value);
    }

}
