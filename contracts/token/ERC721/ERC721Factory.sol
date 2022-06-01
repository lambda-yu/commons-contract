// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "./ERC721Storage.sol";

contract ERC721Factory is ERC721URIStorage  {

    event CreateCollection(address indexed creater, address indexed collectionAddress);

    constructor(string memory name, string memory symbol, string memory baseURI){
        super.init(name, symbol, baseURI);
    }
    
    // new collects
    function newCollection(string memory name, string memory symbol, string memory baseURI) public {
        bytes memory bytecode = type(ERC721URIStorage).creationCode;
    
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, baseURI));
        address tokenAddress;
        assembly {
            tokenAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ERC721URIStorage(tokenAddress).init(name, symbol, baseURI); // init

        emit CreateCollection(msg.sender, tokenAddress);
    }
}