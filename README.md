# NFTOwnable

Make a contract be tradable as an NFT. The instances of NFTOwnable possesses a ERC721Ownership instance that is ERC721 and that triggers the NFTOwnable ownership transfer when it is traded.  

The ERC721Ownership instance always keeps the same NFTOwnable instance as owner in reality, but it acts as if its owner is the owner of the NFTOwnable instance which can be transfered normally or via the NFT. 
