```
pragma solidity ^0.4.0; 

contract HTLC { 
    // duration of contract
    uint public lockTime = 1 seconds;
    // send ETH toAddress
    address public toAddress = 0xdD6fBbd0b8A23aF5eFbDefBF16A3A22497E203c4; 
    // '0x' + sha256('password')
    bytes32 public hash = 0x5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8; 
    // contract starts now
    uint public startTime = now;
    // return address in case the contract times out
    address public fromAddress; 
    // the "password" required to spend the bitcoin transaction
    string public key; 
    // the amount in the contract
    uint public fromValue; 

    function HTLC() payable { 
        fromAddress = msg.sender; 
        fromValue = msg.value; 
    } 

    modifier condition(bool _condition) { 
        require(_condition); _; 
    } 

    // if the hashing the key matches, then transfer ETH toAddress
    function checkKey(string _key) payable condition ( sha256(_key) == hash ) returns (string) { 
        toAddress.transfer(fromValue); 
        key = _key; 
        return key; 
    } 

    // if the contract times out, then return the funds
    function withdraw () payable condition ( startTime + lockTime < now ) returns (uint) { 
        fromAddress.transfer(fromValue); 
        return fromValue; 
    } 

}
```
