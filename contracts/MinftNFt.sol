// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MinftNFt is ERC721URIStorage, Ownable {
    constructor() ERC721("Vishal", "VD") {}

    uint tokenId;

    function mintNFT(string memory tokenURI) public {
        ++tokenId;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    function getCurrentTokenId() public view returns (uint) {
        return tokenId;
    }
}
