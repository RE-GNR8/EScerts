// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @author Sergio Martell - Motley Ds


contract GNR8 is ERC1155, ReentrancyGuard, Ownable {
    string public name;
    string public symbol;
    

    mapping (uint256 => string) private _uris;
    
    mapping (uint256 => uint256) private _prices;

    mapping (uint256 => uint256) private _supplies;

    mapping(uint256 => uint256) private _minted;
    
    

    // Switch to close and open sale;

    bool _saleActive = false;

    event ReleaseMinted(address sender, uint256 quantity, uint256 tokenId);

    constructor() ERC1155("") {
        name = "GNR8";
        symbol = "GNR8";
        
        // Founding Members
        _uris[0] = "https://nftstorage.link/ipfs/bafybeih7xiz7szqwllhtbefj2ksnz7k7pecww5msza3slf2rzcwfvhuzle/";
        _supplies[0] = 10000;
        _prices[0] = .0001 ether;
        _minted[0] = 0;
    }
    
    // Owner Only functions.
    
    function setSaleState(bool _newSaleActive) external onlyOwner {
    _saleActive = _newSaleActive;
    }

    // Owner mint, will reflect on total supply.

    function changeBaseURI(string memory _uri, uint256 tokenId) 
        public 
        onlyOwner
        {
            _uris[tokenId] = _uri;
        }
        
    function changePrice(uint256 _price, uint256 tokenId) 
        public 
        onlyOwner
        {
            _prices[tokenId] = _price;
        }

    /**
    * @dev please take notice of the _uris comment. And make sure that the folder that is uploaded to IPFS has a file with the tokenId as the name (0,1,2,3),
    * the token Ids must me whole numbers.
    */

    function createRegistry(uint256 tokenId, uint256 price, address contributor, string memory baseURI) 
        public         
        {
            _uris[tokenId] = baseURI;
            _supplies[tokenId] = 0;
            _prices[tokenId] = price;
            _mint(contributor, tokenId, 1, "");
        }

    function disburse() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    // API

    function mint(uint256 id, uint256 amount)
        public
        payable
        nonReentrant
    {   
        require(_saleActive, "Sale not active");
        require(_supplies[id] > 0, "This release does not exist.");
        require(_minted[id]+ amount <= _supplies[id], "This release has reached it's limited supply!");
        require(msg.value >= amount * _prices[id], "The amount sent doesn't cover the price for the asset");
        _mint(msg.sender, id, amount, "");
        _minted[id]+= amount;
        emit ReleaseMinted(msg.sender, amount, id);
    }


    function totalSupply(uint256 id) public view returns (uint256 supply){
        return _minted[id];
    }

    /**
    * @dev Returns the URI to the contract metadata as required by OpenSea
    */

    
    function uri(uint256 tokenId) override public view returns (string memory) {
        return(string(abi.encodePacked( _uris[tokenId], Strings.toString(tokenId))));
    }

// fallback functions to handle someone sending ETH to contract

  fallback() external payable {}

  receive() external payable {}

 }