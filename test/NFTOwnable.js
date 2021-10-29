
const { expect } = require("chai");
const BigNumber = require("bignumber.js");
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

const NFTOwnable = artifacts.require("contracts/NFTOwnable.sol:NFTOwnable");
const ERC721Ownership = artifacts.require("contracts/NFTOwnable.sol:ERC721Ownership");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
contract("NFTOwnable", function (accounts) {
  
  let nftownable;
  let owner, newOwner;

  beforeEach(async function () {
    let accounts = await web3.eth.getAccounts();
    [owner, newOwner] = accounts;

    nftownable = await NFTOwnable.new();
  });

  it("shoud create an ERC721Ownership instance at activation", async function () {

    assert.equal(await nftownable.activated(), false);
    await nftownable.activate();

    assert.equal( await nftownable.owner(), owner );    

    let _ownershipAddress = await nftownable.ownership();
    let _ownership = new ERC721Ownership(_ownershipAddress);
    assert.equal( await _ownership.ownerOf(1), owner );

  });

  it("shoud allow NFTOwnable to transfer its own ownership before activation", async function () {
    await nftownable.transferOwnership(newOwner);
    assert.equal( await nftownable.owner(), newOwner );        
  });

  it("shoud prevent NFTOwnable to transfer its own ownership after activation", async function () {

    await nftownable.activate();

    await expectRevert( nftownable.transferOwnership(newOwner),
      "NFTOwnable: cannot transfer ownership directly once activated. Use the ownership token"
    );
  });

  it("shoud allow ERC721Ownership to transfer ownership of the NFTOwnable contract", async function () {
    await nftownable.activate();

    let _ownershipAddress = await nftownable.ownership();
    let _ownership = new ERC721Ownership(_ownershipAddress);

    await _ownership.transferFrom(owner, newOwner, 1);

    assert.equal( await _ownership.ownerOf(1), newOwner ); 
    assert.equal( await nftownable.owner(), newOwner ); 

  });   

});