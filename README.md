# NFTOwnable

Make the ownership of contract become a tradable ERC721 NFT.  

Make your contract inheriting from NFTOwnable and calling activate() will make the ownership of this contract become a ERC721 token. After activation, the contract ownership can only be transfered by transfering the ownership token.  

Drawback: This adds up a lot of bytecode if your contract is not itself ERC721.