//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import '@openzeppelin/contracts/access/Ownable.sol';
import './Ownable.sol'; // lasted version of openzeppelin Ownable
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';


contract ERC721Ownership is ERC721{
    uint constant NFT_ID = 1;
    NFTOwnable public ownedContract;
    bool private _initialized;
    
    constructor() ERC721("ERC721Ownership", "OWN") {
        ownedContract = NFTOwnable(msg.sender);        
        _mint(address(ownedContract), NFT_ID);
        _initialized=true;
    }

    /**
     * @dev Transfer of the token causes transfer of the ownership of ownedContract
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(tokenId==1, "ERC721Ownership: must be tokenId 1");
        require( ownedContract.owner() == from, "ERC721Ownership: transfer of token that is not own");
        require(to != address(0), "ERC721Ownership: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        emit Transfer(from, to, tokenId);

        ownedContract.ownershipTransfer(to); // transfers the contract instead of the NFT
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        require(tokenId==1, "ERC721Ownership: must be tokenId 1");
        return ownedContract.owner();
    }    

}

contract NFTOwnable is Ownable{
    ERC721Ownership private _ownership;
    bool private _activated;

    constructor(){
        // cannot activate in constructor because address(this) must be set
    }

    // activate to allow NFT trading
    function activate() external onlyOwner{
         _activate();
    }

    function activated() external view returns (bool){
        return _activated;
    }

    function _activate() internal {
        require(!_activated, 'NFTOwnable: already activated');
        _ownership = new ERC721Ownership();
         //_ownership.transferFrom(address(this), owner(), 1);
        _ownership.approve( owner(), 1);         
        _activated=true;
    }    

    function ownership() public view returns (address){
        require(_activated, "NFTOwnable: not activated, no ownership yet");
        return address(_ownership);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Only callable by _ownership
     */
    function ownershipTransfer(address newOwner) external {
        require( address(_ownership)== _msgSender(), "NFTOwnable: caller is not the owner or ownership");        
        super._transferOwnership(newOwner);
        _ownership.approve( newOwner, 1);  
    }    
    
}
