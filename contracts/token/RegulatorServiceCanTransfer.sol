pragma solidity ^0.4.24;

contract RegulatorServiceCanTransfer {

  /**
   * @notice This method is called by `AtomicToken` during `transfer()` and `transferFrom()`
   *         The implementation should contain all restrictions logic on tranfer of tokens
   * @param  _token The address of the token to be transfered
   * @param  _spender The address of the spender of the token
   * @param  _from The address of the sender account
   * @param  _to The address of the receiver account
   * @param  _amount The quantity of the token to trade
   * @return Bytecode that signifies approval or reason for restriction; hex"01" means successful transfer
   *         All other values are left to the implementer to assign meanings
   */
    function verify(address _token, address _spender, address _from, address _to, uint256 _amount)
        public 
        view 
        returns (byte) 
    {
        return hex"01";
    }

   /**
    * @notice This method returns a human-readable message for a given bytecode
    * @dev Implementer must assign custom codes for each restriction reason
    * @param restrictionCode Bytecode identifier for looking up message
    * @return Text with reason for restriction 
    */
    function restrictionMessage(byte restrictionCode)
        public
        view
        returns (string)
    {
    	if(restrictionCode == hex"01") {
    		return "No restrictions detected";
        }
    }
}