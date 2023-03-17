// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "../src/Auction.sol";
import "../src/KZN.sol";

contract AuctionTest is Test {
    Auction public auction;
    NFT public kzn;

    function setUp() public {
        auction = new Auction();
        kzn = new NFT(address(auction));
      kzn.safeMint("https://ipfs.filebase.io/ipfs/QmYqEcCNJiP7pP2nzSsvyv7Ji1tNpv6omWMJ4Nph22dmfn");
      auction.CreateAuction{value: 0.0065 ether}(address(kzn), 0, 1 ether);   
    }

    function testsafeMint() public view {
        auction.getAuctionedItem();
    }

    function testbid() public payable {
        auction.startBidding(1);
        vm.startPrank(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC));
        vm.deal(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC), 5 ether);  
        auction.bid{value: 2 ether}(1);
        vm.stopPrank();
        vm.startPrank(address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720));
        vm.deal(address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720), 9 ether);
        auction.bid{value: 3 ether}(1);
        vm.stopPrank();
        auction.getSeller(1);
        uint balance = address(auction).balance;
        console.log(balance);
        auction.settleBid(1);
        vm.startPrank(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC));
        auction.withdraw(1);
        vm.stopPrank();
        // auction.cashOut(1);
        auction.withdrawContractFunds();
         uint balance2 = address(auction).balance;
        console.log(balance2);

    }

}
