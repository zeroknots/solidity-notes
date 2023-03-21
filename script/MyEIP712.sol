// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/draft-EIP712.sol";

contract MyEIP712 is EIP712 {
    struct MyData {
        address owner;
        uint256 myParam;
        uint256 nonce;
        uint256 deadline;
    }

    mapping(address => MyData) public userToData;
    mapping(address => uint256) public nonces;

    constructor() EIP712("MyEIP712", "4") {}

    function getDigest(address owner, uint256 myParam, uint256 deadline) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256("MyData(address owner,uint256 myParam,uint256 nonce,uint256 deadline)"),
                    owner,
                    myParam,
                    nonces[owner],
                    deadline
                )
            )
        );
    }

    function executeMyFunctionFromSignature(bytes memory signature, address owner, uint256 myParam, uint256 deadline)
        external
    {
        bytes32 digest = getDigest(owner, myParam, deadline);
        address signer = ECDSA.recover(digest, signature);
        if (signer == address(0)) revert AddressZero();
        if (signer != owner) revert InvalidSignature();
        if (block.timestamp > deadline) revert ExpiredSignature();
        console2.log("MyData: signature verified");

        userToData[owner] = MyData(signer, myParam, nonces[owner], deadline);

        nonces[owner]++;
    }

    error InvalidSignature();
    error ExpiredSignature();
    error AddressZero();
}

contract DemoEIP712 is Script {
    MyEIP712 myEIP712;

    function setUp() public {
        myEIP712 = new MyEIP712();
    }

    function run() public {
        uint256 privKey = 1;
        address addr = vm.addr(privKey);

        uint256 deadline = block.timestamp + 1000;
        bytes32 msgHash = myEIP712.getDigest(addr, 1, deadline);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, msgHash);

        bytes memory signature = abi.encodePacked(r, s, v);
        myEIP712.executeMyFunctionFromSignature(signature, addr, 1, deadline);
    }
}
