# Atomic Digital Security Standard
An extendable smart contract standard for digital security issuance and automated regulatory compliance.
## Overview
The Atomic Digital Security Standard (DSS) is a permissioned, ERC-20 compatible digital security that enforces transfer restrictions based on an upgradable `RegulatorService` contract. Once deployed, the `RegulatorService` can be replaced and configured to maintain ongoing compliance with securities regulations e.g. the enforcement of KYC/AML requirements, accredited investor checks, trading lock-up periods, tax laws, and other contractual agreements. The Atomic DSS architecture allows securities issuers to automate enforcement of a modifiable list of restrictions, while also providing the flexibility to update these restrictions to adapt to changes to regulations, governance, and/or business requirements that could emerge in the future. 
## Requirements
* The Atomic DSS overrides standard ERC-20 functions `transfer()` and `transferFrom()` with additional checks to determine whether a transfer ought to be restricted. This is implemented by calling `verify()` from inside the current `RegulatorService` to supply the necessary restrictions logic.
* The `verify()` function returns byte code that signals the status of a transfer and the specific reason for a restriction if it occurs. Additionally, the `RegulatorService` implements `restrictionMessage()` that returns a human-readable error message corresponding to a given byte code.
* In order to allow for upgrading the digital security's restrictions logic, the Atomic DSS abstracts the `RegulatorService` by storing a reference to its contract address and implements `replaceRegulator()` that changes the pointer to a new `RegulatorService`.
## Specification
Atomic DSS builds on the ERC-20 standard and provides additional functionality:
```solidity
contract AtomicDSS is ERC20, Ownable {
event ReplaceRegulator(address oldRegulator, address newRegulator);

modifier notRestricted (address _from, address _to, uint256 _value);
modifier isContract (address _addr);

function replaceRegulator(RegulatorService _regulator) public onlyOwner isContract(_regulator);
function transfer(address _to, uint256 _value) public notRestricted returns (bool);
function transferFrom(address _from, address _to, uint256 _value) public notRestricted returns (bool);

function mint(address _account, uint256 _amount) public onlyOwner returns (bool);
function burn(address _account, uint256 _amount) public onlyOwner returns (bool);
function forceTransfer(address _from, address _to, uint256 _value) public onlyOwner returns (bool);
}
```

The `RegulatorService` contains all the restrictions logic and an error messaging system:
```solidity
contract RegulatorService {
function verify(address _token, address _spender, address _from, address _to, uint256 _amount) public view returns (byte);
function restrictionMessage(byte restrictionCode) public view returns (string);
}
```
