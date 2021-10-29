//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import '@openzeppelin/contracts/access/Ownable.sol';
import './Ownable.sol'; // lasted version of openzeppelin Ownable
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';


/**
 * @dev Module to make the ownership of a smart contract a tradable ERC721 token
 * NOTE: This module should only be deployed by a contract implementing NFTOwnable
 */ 
contract ERC721Ownership is ERC721{
    uint constant NFT_ID = 1;
    NFTOwnable public _ownedContract;
    
    /**
     * @dev Mint the single token of the contract to the initial owner at deployment
     */    
    constructor(address initialOwner) ERC721("ERC721Ownership", "OWN") {
        _mint(initialOwner, NFT_ID);
        _ownedContract = NFTOwnable(msg.sender);                
    }

    function ownedContract() external view returns (address){
        return address(_ownedContract);
    }

    /**
     * @dev Transfer of the token also causes transfer of the ownership of _ownedContract
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(to != address(0), "ERC721Ownership: transfer to the zero address");
        if(address(_ownedContract)!=address(0)){
            _ownedContract.ownershipTransfer(to);
        }
    }  

}


/**
 * @dev Module to make the ownership of a smart contract a tradable ERC721 token
 * NOTE: inheriting from this module and calling activate() will make the ownership
 * of a contract a ERC721 token.
 */ 
contract NFTOwnable is Ownable{
    ERC721Ownership private _ownership;

    constructor(){
        // cannot activate in constructor because address(this) must be set
    }

    // activate to allow NFT trading
    function activate() external onlyOwner{
        require(!activated(), 'NFTOwnable: already activated');
        _ownership = new ERC721Ownership(owner());
    }

    function activated() public view returns (bool){
        return address(_ownership) != address(0);
    }  

    function ownership() public view returns (address){
        require(activated(), "NFTOwnable: not activated, no ownership yet");
        return address(_ownership);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) if not activated
     * Prevent transfering ownership if activated
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        if(activated()){
            revert("NFTOwnable: cannot transfer ownership directly once activated. Use the ownership token");
        }else{
            super.transferOwnership(newOwner);
        }
    }    

    modifier onlyOwnershipToken(){
        require( address(_ownership) == _msgSender(), "NFTOwnable: caller is not the owner or ownership");        
        _;
    }

    /**
     * @dev _ownership token transfers ownership of the contract to a new account (`newOwner`).
     * Only callable by address _ownership
     */
    function ownershipTransfer(address newOwner) external onlyOwnershipToken{
        super._transferOwnership(newOwner);
    }    
    
}
