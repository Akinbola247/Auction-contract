// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
contract Auction is Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private auctionID;
    enum Status { start, end}
    struct AuctionDetails {
        address contractAddress;
        address NFTowner;
        uint tokenID;
        uint price;
    }
    struct ItemsToAuction {
        uint AuctionID;
        address contractAddress;
        uint tokenID;
        Status status;
        uint price;
    }
    ItemsToAuction itemsToAuction;
    mapping(uint => ItemsToAuction) TobeAuctioned;
    AuctionDetails auctionDetails;
    mapping (address => AuctionDetails) OwnerAuctionItem;
    uint private highestBid;
    address payable private highestBidder;
    mapping (address => uint)bids;
    mapping (uint => address) seller;
    
    
constructor() public payable{}
    function CreateAuction (address contractAddress, uint tokenID, uint price) public payable {
       require(msg.value == 0.0065 ether, "listing Price is 0.00065 ether");
        auctionID.increment();
        uint256 itemIds = auctionID.current();
       AuctionDetails storage _b = OwnerAuctionItem[msg.sender];
       _b.contractAddress = contractAddress;
       _b.NFTowner = msg.sender;
       _b.tokenID = tokenID;
       _b.price = price;
       ItemsToAuction storage _a = TobeAuctioned[itemIds];
       _a.AuctionID = itemIds;
       _a.contractAddress = contractAddress;
       _a.tokenID = tokenID;
       _a.status = Status.end;
       _a.price = price;
       seller[itemIds] = payable(msg.sender);
       IERC721(contractAddress).transferFrom(msg.sender, address(this), tokenID);
    }
    function getAuctionedItem() public view returns (address, uint) {
        AuctionDetails memory auctionedItem = OwnerAuctionItem[msg.sender];
        return (auctionedItem.contractAddress, auctionedItem.tokenID);
    }

    function startBidding(uint _auctionID) public onlyOwner {
        ItemsToAuction storage _id = TobeAuctioned[_auctionID];
        _id.status = Status.start;
    }

    function getSeller(uint id) public view returns(address _seller){
        _seller = seller[id];
    }
    function bid(uint auctionID_) public payable{
        ItemsToAuction storage id_ = TobeAuctioned[auctionID_];
        uint bidderStatus = bids[msg.sender];
        require(id_.status == Status.start, "Auction is not open");
        require(msg.value >= id_.price, "price below auction");
        require(msg.value != 0, "cannot bid 0");
        require(msg.value > highestBid, "highestBidder exists");
        require(bidderStatus == 0, "Cannot bid twice");
        if(highestBid !=0 && msg.value > highestBid){
            bids[msg.sender] += msg.value;
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
        }else {
            bids[msg.sender] += msg.value;
            highestBid = msg.value;
            highestBidder = payable(msg.sender);        
         }  
    }

    function withdraw(uint auctionID__) public {
        uint balance = bids[msg.sender];
        ItemsToAuction storage _id_ = TobeAuctioned[auctionID__];
        require(balance != 0, "you have no bid");
        require (msg.sender !=highestBidder, "You're the highestBidder");
        require(_id_.status == Status.end, "Auction has not closed");
        (bool sent, ) = payable(msg.sender).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    function settleBid(uint auctionIDm__) public payable onlyOwner{
        ItemsToAuction storage _idm_ = TobeAuctioned[auctionIDm__];
        require(_idm_.status == Status.start, "Auction not active");
        _idm_.status = Status.end;
        address contractaddr = _idm_.contractAddress;
        uint nftID = _idm_.tokenID;
        IERC721(contractaddr).transferFrom(address(this), highestBidder, nftID);
    }

    function cashOut(uint _itemMarketID) external payable {
        address _seller = seller[_itemMarketID];
        require(msg.sender == _seller, "Not Authorized");
         (bool sent, ) = payable(msg.sender).call{value: highestBid}("");
        require(sent, "Failed to send Ether");
    }

receive() external payable{}
fallback() external payable{}
}


//list NFT for auction
//buyers should be able to bid 
// Auction owner should start auction
// At auction end , NFT should transfer to highest bidder and ether should be sent to owner