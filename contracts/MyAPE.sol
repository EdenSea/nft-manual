// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyAPE is ERC721, PullPayment, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    // Constants
    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.01 ether;

    /// @dev Base token URI used as a prefix by tokenURI().
    string public baseTokenURI;

    constructor() ERC721("MYAPE", "APE") {
        baseTokenURI = "";
    }
    
    function mintTo(address recipient)
        public payable
        returns (uint256)
    {
        uint256 tokenId = currentTokenId.current();
        require(tokenId <= TOTAL_SUPPLY, "Max supply reached");
        require(msg.value == MINT_PRICE, "value not equal the mint price");

        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    /// @dev Returns an baseURI 
    function _baseURI() internal view virtual override returns (string memory) {
      return baseTokenURI;
    }

    /// @dev Sets the base token URI prefix.
    function setBaseTokenURI(string memory _baseTokenURI) public {
      baseTokenURI = _baseTokenURI;
    }

    /// @dev Overridden in order to make it an onlyOwner function
    function withdrawPayments(address payable payee) public override onlyOwner virtual {
        super._asyncTransfer(payee,address(this).balance);
        super.withdrawPayments(payee);
    }
}
