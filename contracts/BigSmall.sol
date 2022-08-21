//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract BigSmall is VRFConsumerBase, Ownable {
    address payable public currentPlayer;
    uint256 public randomness;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum CASINO_STATE {
        OPEN,
        CLOSED
    }
    CASINO_STATE public casino_state;
    uint256 public fee;
    bytes32 public keyhash;
    event RequestedRandomness(bytes32 requestId);
    bool public isBig;
    uint256 public lastRolled = 10;
    uint256 public enteredFee;
    bool public didWin = false;

    // 0
    // 1
    // 2

    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        //$20 entry
        usdEntryFee = 20 * 10**18;
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        casino_state = CASINO_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
        isBig = false;
    }

    function startCasino() public onlyOwner {
        require(
            casino_state == CASINO_STATE.CLOSED,
            "Can't start a new casino yet!"
        );
        casino_state = CASINO_STATE.OPEN;
    }

    function donate() public payable {
        require(msg.value > 0);
    }

    function enterSmall() public payable {
        // $20 minimum
        require(casino_state == CASINO_STATE.OPEN, "Casino is in use");
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        currentPlayer = msg.sender;
        casino_state = CASINO_STATE.CLOSED;
        isBig = false;
        enteredFee = msg.value;
        calculateWinner();
    }

    function enterBig() public payable {
        // $20 minimum
        require(casino_state == CASINO_STATE.OPEN, "Casino is in use");
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        currentPlayer = msg.sender;
        casino_state = CASINO_STATE.CLOSED;
        isBig = true;
        enteredFee = msg.value;
        calculateWinner();
    }

    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10;
        uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice;
        return costToEnter;
    }

    function calculateWinner() internal {
        bytes32 requestId = requestRandomness(keyhash, fee);
        //casino_state = CASINO_STATE.OPEN;
        emit RequestedRandomness(requestId);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(casino_state == CASINO_STATE.CLOSED, "You aren't there yet!");
        require(_randomness > 0, "random-not-found");
        uint256 rolledNumber = _randomness % 10;
        lastRolled = rolledNumber;
        if (
            (rolledNumber < 5 && isBig == false) ||
            (rolledNumber > 5 && isBig == true)
        ) {
            if (address(this).balance < enteredFee * 2) {
                currentPlayer.transfer(address(this).balance);
            } else {
                currentPlayer.transfer(enteredFee * 2);
            }
            didWin = true;
        } else {
            didWin = false;
        }
        // Reset
        enteredFee = 0;
        casino_state = CASINO_STATE.OPEN;
        randomness = _randomness;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}
