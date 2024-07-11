// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HTLC {
    // each vault holds funds
    struct Vault {
        address from; // address making the deposit
        uint256 value; // value to send
        address to; // address sending funds to
        uint256 time; // time until swap expires
        bool done; // true if vault is withdraw() or refund()
    }

    // each vault is locked with a bytes32 sha256 hash
    mapping(bytes32 => Vault) public vault;

    function deposit(address _to, bytes32 _hash) public payable {
        // requie value has value
        require(msg.value > 0, "Value empty");
        // require new deposit
        require(vault[_hash].time == 0, "Vault exists");
        // set values
        vault[_hash] =
            Vault({from: msg.sender, value: msg.value, to: _to, time: block.timestamp + 5 minutes, done: false});
    }

    function withdraw(bytes32 _preimage) public {
        // hash the preimage
        bytes32 hash = sha256(abi.encodePacked(_preimage));
        // require vault has value
        require(vault[hash].value > 0, "Vault empty");
        // require vault is not closed
        require(!vault[hash].done, "Vault closed");
        // vault is done
        vault[hash].done = true;
        // transfer value to address
        payable(vault[hash].to).transfer(vault[hash].value);
    }

    function refund(bytes32 _hash) public {
        // require vault is not closed
        require(!vault[_hash].done, "Vault closed");
        // require vault is expired 
        require(block.timestamp > vault[_hash].time, "Vault unexpired");
        // vault is done
        vault[_hash].done = true;
        // transfer value back from address
        payable(vault[_hash].from).transfer(vault[_hash].value);
    }
}
