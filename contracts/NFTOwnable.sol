//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import '@openzeppelin/contracts/access/Ownable.sol';
import './Ownable.sol'; // lasted version of openzeppelin Ownable


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
