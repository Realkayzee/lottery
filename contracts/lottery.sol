// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.8.9;
/// @title A lottery contract
/// @dev Kayzee

// Players can only play if they pay the entry fee for the lottery
// Players can check the entry fee before playing
// Lottery owner can specify the maximum number of players that can participate
// Winner receive half of the total amount deposited by all users and the rest is reserved in the contract
contract Lottery{
    event _startGame(uint128 _maxPlayers, uint256 _entryFee, uint256 lotteryId, bool started);
    event _getwinner(address winner);

    error _getWinner(string);

    address owner;
    address[] players;
    uint128 maxPlayers;
    uint256 public baseEntry;
    bool started;
    uint256 lotteryId;


    constructor() {
        owner = msg.sender;
    }

// Owner specify the number of players
// Owner specify the base fee or entry fee
    function startGame(uint128 _maxPlayers, uint256 _entryFee) public {
        require(msg.sender == owner, "You are not an owner");
        require(!started, "The game have started already");
        delete players;
        maxPlayers = _maxPlayers;
        started = true;
        baseEntry = _entryFee;
        lotteryId += 1;

        emit _startGame(_maxPlayers, _entryFee, lotteryId, started);
    }

    function randomNum() public view returns(uint){
        uint256 lotNumber = uint256(keccak256(abi.encodePacked(block.timestamp, owner)));
        return lotNumber % players.length;
    }

    function participate() public payable{
        require(started, "Game have not started");
        require(msg.value >= baseEntry, "Amount is not upto entry fee to participate");
        require(players.length < maxPlayers, "Players exceeded");
        players.push(msg.sender);
    }

    function getWinner() external returns(address winner){
        if(players.length == maxPlayers){
            winner = players[randomNum()];
            (bool sent, ) = winner.call{value: address(this).balance/2}("");
            require(sent, "Transaction failed");
            started = false;
            emit _getwinner(winner);
        }
        else{
            revert _getWinner("Max players have not been attained");
        }
    }
    function getContractBal() view external returns(uint256){
        return address(this).balance;
    }
}