pragma solidity ^0.4.18;
import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;
// TODO: place your code here
    uint public startTime;
    uint public endTime;
    uint public reservePrice;
    uint public currentPrice;
    Timer public timer;
    address public contractAddress;
    bool sealed = false;


    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement) public
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;
        // TODO: place your code here
        timer = Timer(_timerAddress);
        startTime = timer.getTime();
        endTime = startTime + biddingPeriod;
        contractAddress = address(this);

    }

    modifier onlyInTimePeriod() {
      require( endTime > timer.getTime(), "Out of auction time window.");
      _;
    }

    modifier onlyIfNotSealed() {
      require( sealed == false, "Out of auction time window.");
      _;
    }

    function getTime() internal view returns (uint time) {
      return timer.getTime();
    }

    function bid() public payable onlyIfNotSealed() onlyInTimePeriod() {
        // TODO: place your code here
        currentPrice = initialPrice - (offerPriceDecrement * (getTime() - startTime));

        if (contractAddress.balance < currentPrice) {
          revert("Bid is lower than current price.");
        }
        sealed = true;

        winnerAddress = msg.sender;

        if (contractAddress.balance > currentPrice) {
          msg.sender.transfer(contractAddress.balance - currentPrice);
        }
    }

}
