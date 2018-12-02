pragma solidity ^0.4.18;
import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;

    // TODO: place your code here
    uint currentTime;
    uint startTime;
    uint formerHighestBid;
    uint oldBalance;
    Timer timer;
    address contractAddress;
    address formerHighestBidder;
    mapping(address=>uint) priorBids;

    event printStr(string str);
    event print(uint256 value);

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement) public
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;
        // TODO: place your code here
        timer = Timer(_timerAddress);
        startTime = timer.getTime();
        contractAddress = address(this);

    }

    modifier onlyInTimePeriod() {
      require( startTime + biddingPeriod > timer.getTime(), "Out of auction time window.");
      _;
    }


    function getTime() internal view returns (uint time) {
      return timer.getTime();
    }

    function bid() public payable onlyInTimePeriod() {
        // TODO: place your code here
        emit printStr("Bid");
        emit print( contractAddress.balance - oldBalance);
        emit printStr("should be higher than");
        emit printStr("former bid");
        emit print(formerHighestBid);

        if (formerHighestBid + minimumPriceIncrement > contractAddress.balance - oldBalance) {
          revert("This bid is not high enough");
        }

        if (contractAddress.balance < initialPrice) {
          revert("This bid is not high enough");
        }

        priorBids[formerHighestBidder] += formerHighestBid;
        formerHighestBidder = msg.sender;
        formerHighestBid = contractAddress.balance - oldBalance;
        startTime = getTime();
        oldBalance = contractAddress.balance;
    }

    // Need to override the default implementation
    function getWinner() public view returns (address highestBidder){
      // TODO: place your code here
        if (startTime + biddingPeriod > timer.getTime()) {
          return 0;
        }
        else { return formerHighestBidder; }
    }

    function withdraw() public {
      msg.sender.transfer(priorBids[msg.sender]);
      priorBids[msg.sender] = 0;
    }
}
