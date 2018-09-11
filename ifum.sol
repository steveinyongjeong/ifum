pragma solidity ^0.4.24;

import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";

contract IFUM is Ownable, ERC20Burnable {

    string public version = "0.1.00";

    string public name;
    
    string public symbol;
    
    uint8 public decimals;

    address private _crowdsale;

    bool private _freezed;

    mapping (address => bool) private _locked;
    
    constructor(address crowdsale) public {
        symbol = "IFUM";
        name = "INFLEUM Token";
        decimals = 8;
        _crowdsale = crowdsale;
        _mint(crowdsale, 3000000000 * 10 ** uint(decimals));
        _freezed = true;
    }

    function isFreezed() public view returns (bool) {
        return _freezed;
    }

    function unfreeze() public {
        require(msg.sender == _crowdsale);
        _freezed = false;
    }

    function isLocked(address account) public view returns (bool) {
        return _locked[account];
    }

    modifier test(address account) {
        require(!isLocked(account) && (!_freezed || _crowdsale == account));
        _;
    }

    function lockAccount(address account) public onlyOwner {
        require(!isLocked(account));
        _locked[account] = true;
        emit LockAccount(account);
    }

    function unlockAccount(address account) public onlyOwner {
        require(isLocked(account));
        _locked[account] = false;
        emit UnlockAccount(account);
    }

    function transfer(address to, uint256 value) public test(msg.sender) returns (bool) {
        return super.transfer(to, value);
    }

    function approve(address spender, uint256 value) public test(msg.sender) returns (bool) {
        return super.approve(spender, value);
    }

    function transferFrom(address from, address to, uint256 value) public test(from) returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public test(msg.sender) returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public test(msg.sender) returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function burn(uint256 value) public test(msg.sender) {
        return super.burn(value);
    }

    function burnFrom(address from, uint256 value) public test(from) {
        return super.burnFrom(from, value);
    }

    event LockAccount(address indexed account);

    event UnlockAccount(address indexed account);
}