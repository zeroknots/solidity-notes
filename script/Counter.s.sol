// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";


import "@openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin-contracts/contracts/utils/cryptography/draft-EIP712.sol";

contract MyEIP712 is EIP712 {
    function executeMyFunctionFromSignature(
        bytes memory signature,
        address owner,
        uint256 myParam,
        uint256 deadline
    ) external {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("MyFunction(address owner,uint256 myParam,uint256 nonce,uint256 deadline)"),
            owner,
            myParam,
            nonces[owner],
            deadline
        )));

        address signer = ECDSA.recover(digest, signature);
        require(signer == owner, "MyFunction: invalid signature");
        require(signer != address(0), "ECDSA: invalid signature");

        require(block.timestamp < deadline, "MyFunction: signed transaction expired");
        nonces[owner]++;

        _myFunction(owner, myParam);
    }
}

contract NotesEIP712 is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
