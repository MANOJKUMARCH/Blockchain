pragma solidity^0.4.23;

/*
looking to get someone to write the smart contract for 2 casino games.
we'd expect the games to be written in Solidity and include unit tests.
the games/contract are

coinflip
user 1 puts in X amount of ETH, user 2 puts in the same amount, when the game it played one player get their original amount of ETH, plus the other users amount, minus a commission, which goes to user 3 (the house)

jackpot
same as above, except 10 users put in X amount, one user wins and gets the ETH from all users, minus a commission that goes to user 11 (the house)
*/

contract CasinoGames{
    
    address theHouse;
    uint houseCommission;
    uint8 i;
    //address[2] coinFlipPlayers;
    //mapping(address => uint) playerAmount;
    players[2] coinFlipPlayers;
    players[] jackpotPlayers;
    
    struct players{
        address player;
        uint amount;
    }
    
    event startCoinFlip(string);
    
    constructor() public{
        theHouse = msg.sender;
    }
    
    function coinFlip()public payable{
        require(msg.value >= 1 ether);
        players memory temp = players(msg.sender,msg.value);
        coinFlipPlayers[i] = temp;
        i++;
        if (coinFlipPlayers[1].amount != 0){
            emit startCoinFlip("Both players registered. Start the game");
        }
    }
}