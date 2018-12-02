pragma solidity ^0.4.18;
import "./Timer.sol";

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    address internal contractAddress;
    bool finalized;
    bool refund_tx;
    uint winningPrice;

    // TODO: place your code here

    // constructor
    constructor(address _sellerAddress,
                     address _judgeAddress,
                     address _timerAddress) public {

        judgeAddress = _judgeAddress;
        timerAddress = _timerAddress;
        sellerAddress = _sellerAddress;
        contractAddress = address(this);
        finalized = false;
        if (sellerAddress == 0)
          sellerAddress = msg.sender;
    }

    modifier onlyBy(address _valid) {
      require(
        msg.sender == _valid,
        "This address is not able to call this function (only one address can)."
      );
      _;
    }

    modifier onlyByOr(address _valid1, address _valid2) {
      require(
        msg.sender == _valid1 || msg.sender == _valid2,
        "This address is not able to call this function (only two addresses can)."
      );
      _;
    }

    modifier onlyAfterTimer() {
      require(
        time() != 0,
        "Time is invalid to call this function."
      );
      _;
    }

    modifier onlyIfExistsWinner() {
      require(
        winnerAddress != 0,
        "There is no winner yet."
      );
      _;
    }

    // This is provided for testing
    // You should use this instead of block.number directly
    // You should not modify this function.
    function time() public view returns (uint) {
        if (timerAddress != 0)
          return Timer(timerAddress).getTime();

        return block.number;
    }

    function getWinner() public view returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public onlyIfExistsWinner() {
        if (judgeAddress == 0) {
          finalized = true;
          withdraw();
        }
        else {
          if (msg.sender == judgeAddress || msg.sender == winnerAddress) {
            finalized = true;
            withdraw();
          }
          else {
            revert('Unauthorized call.');
          }
        }
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public onlyIfExistsWinner() onlyByOr( sellerAddress, judgeAddress ) {
        // TODO: place your code here
        refund_tx = true;
        this.withdraw();
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public onlyIfExistsWinner() {
        //TODO: place your code here
        if ( refund_tx == true) {
          winnerAddress.transfer(contractAddress.balance);
        }
        else if ( msg.sender == sellerAddress || msg.sender == judgeAddress ) {
          sellerAddress.transfer(contractAddress.balance);
        }
    }

}
