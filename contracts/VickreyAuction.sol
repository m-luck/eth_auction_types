pragma solidity ^0.4.18;
import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;

    // TODO: place your code here
    uint oldBalance;
    uint highestBidThusFar;
		uint bidValue;
    address highestBidderThusFar;
		bytes32 bid_bytes;
    uint secondHighestBid;
		bytes32 supposedHash;
    mapping(address=>bytes32) commitments;
    mapping(address=>uint) bids;

    event print(bytes32 b3 );
    event printInt(uint u);
    event printStr(string str);
    event printAdd(address add);

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            address _timerAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount) public
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        secondHighestBid = minimumPrice;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;

        // TODO: place your code here
    }

    modifier onlyInTimePeriod(uint endTime) {
      require( endTime > time(), "Out of auction time window.");
      _;
    }

    modifier onlyAfter(uint startTime) {
      require( time() >= startTime, "Cannot be called yet.");
      _;
    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable onlyInTimePeriod(biddingDeadline) {
        // // NOOP to silence compiler warning. Delete me.
        // bidCommitment ^= 0;
				bytes32 commitment = commitments[msg.sender];
        // TODO: place your code here
        if (commitment==0) // If it is not zero, then we can update the commitment for free.
          if (address(this).balance != oldBalance + bidDepositAmount) revert('Deposit is not correct');
        if (commitment!=0 && address(this).balance != oldBalance) revert('No need for another deposit.');
        commitments[msg.sender] = bidCommitment;
        oldBalance = address(this).balance;
    }

		function checkHashes(bytes32 nonce) internal returns (bool matches){
			bidValue = address(this).balance - oldBalance;
			bid_bytes = bytes32(bidValue);
			supposedHash = keccak256(abi.encodePacked(bid_bytes, nonce));
			if (supposedHash != commitments[msg.sender]) {
				return false;
			}
			return true;
		}

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(bytes32 nonce) public payable onlyAfter(biddingDeadline) onlyInTimePeriod(revealDeadline) returns(bool isHighestBidder) {
        // // NOOPs to silence compiler warning. Delete me.
        // nonce ^= 0;
        isHighestBidder = false;

        // TODO: place your code here

        // emit printStr("Supposed");
        // emit print(supposedHash);
        // emit printStr("should be in hashmap: ");
        // emit print(commitments[msg.sender]);

        if (!checkHashes(nonce))
          revert("Something does not hash out...");
        delete commitments[msg.sender];

				bidValue = address(this).balance - oldBalance;
        bids[msg.sender] = bidValue;

        if (bidValue > highestBidThusFar) {
          if (bidValue >= minimumPrice) isHighestBidder = true;
          if (highestBidThusFar != 0) secondHighestBid = highestBidThusFar;
          highestBidThusFar = bidValue;
          highestBidderThusFar = msg.sender;
          // emit printStr("Updating highest bidder");
          // emit printAdd(msg.sender);
        }

        else {
          secondHighestBid = bidValue;
        }

        oldBalance = address(this).balance;
        return isHighestBidder;
    }

    // Need to override the default implementation
    function getWinner() public view onlyAfter(revealDeadline) returns (address winner) {
        // TODO: place your code here
        // emit printStr("highest bidder is");
        // emit printAdd(highestBidderThusFar);
        winner = highestBidderThusFar;
        return winner;
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public onlyAfter(revealDeadline) {
        // TODO: place your code here

        emit printStr("highest");
        emit printInt(highestBidThusFar);
        emit printStr("minus second");
        emit printInt(secondHighestBid);

        bids[highestBidderThusFar] = highestBidThusFar - secondHighestBid;
        // call the general finalize() logic
    }

    function withdraw() public {
      emit printStr("withdraw");
      emit printInt(bidDepositAmount);
      emit printInt(address(this).balance);
			if (bids[msg.sender]!=0) { msg.sender.transfer(bidDepositAmount + bids[msg.sender]); }
			else { msg.sender.transfer(bidDepositAmount); }

      delete bids[msg.sender];
    }

}
