// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "./ERC721-INIT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721URIStorage is ERC721Init {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _counter;
    
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    string private _bURI;

    bool private _isInit;

    function init(string memory name, string memory symbol, string memory baseURI) public {
        require(!_isInit, "is inited!");
        super.init(name, symbol);
        setBaseUri(baseURI);
        _isInit = true;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _baseURI() internal view override returns(string memory) {
        return _bURI;
    }

    function setBaseUri(string memory uri)public {
        _bURI = uri;
    }

    // new token
    function mint(string memory tokenURI_) public {
        uint256 tokenID = _counter.current();
        _safeMint(_msgSender(), tokenID);
        _counter.increment();
        _setTokenURI(tokenID, tokenURI_);
    }

    function burn(uint256 tokenID) public {
        require(ownerOf(tokenID) == _msgSender(), "this token not owner of you!");
        _burn(tokenID);
    }
}