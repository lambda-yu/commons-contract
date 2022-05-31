// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "./ERC20-INIT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Factory {
    using Counters for Counters.Counter;
    mapping(uint256 => address) private _tokenAddress;
    mapping(string => uint256) private _tokenId;

    Counters.Counter private _counter;

    constructor() {
        _counter.increment();
    }

    event CreateToken(address indexed tokenAddress, uint256 indexed tokenId);

    function newToken(string calldata tokenName, string calldata tokenSymbol, uint8 tokenDecimal, uint256 tokenTotalSupply) public{
        require(tokenTotalSupply > 0, "totalsupply must less then zero");
        require(_tokenId[tokenName] == 0, "this token name is exists");

        bytes memory bytecode = type(ERC20).creationCode;
        uint256 tokenId = _counter.current();

        bytes32 salt = keccak256(abi.encodePacked(tokenName, tokenSymbol, tokenDecimal, tokenTotalSupply, tokenId));
        address tokenAddress;
        assembly {
            tokenAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ERC20(tokenAddress).init(tokenName, tokenSymbol, tokenDecimal, tokenTotalSupply, msg.sender); // init

        _tokenId[tokenName] = tokenId;
        _tokenAddress[tokenId] = tokenAddress;

        emit CreateToken(tokenAddress, tokenId);
    }

    function getTokenById(uint256 tokenID) public view returns(address) {
        return _tokenAddress[tokenID];
    }

    function getTokenByName(string calldata tokenName) public view returns(address) {
        return _tokenAddress[_tokenId[tokenName]];
    }
}