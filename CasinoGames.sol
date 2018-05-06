pragma solidity^0.4.23;

/*
smart contract for 2 casino games.
we'd expect the games to be written in Solidity and include unit tests.
the games/contract are

coinflip
user 1 puts in X amount of ETH, user 2 puts in the same amount, when the game it played one player get their original amount of ETH, plus the other users amount, minus a commission, which goes to user 3 (the house)

jackpot
same as above, except 10 users put in X amount, one user wins and gets the ETH from all users, minus a commission that goes to user 11 (the house)

here in this code, i have used below game codes, also the jackpot is made for unlimited members
coinflip --> 111
jackpot --> 222
*/

contract CasinoGames{
    
    address theHouse;
    uint houseCommission;
    uint i;
    uint j;
    uint coinFlipAmount;
    uint jackpotAmount;
    //address[2] coinFlipPlayers;
    //mapping(address => uint) playerAmount;
    players[2] coinFlipPlayers;
    players[] jackpotPlayers;
    
    struct players{
        address player;
        uint amount;
    }
    
    event startGame(string);
    
    modifier onlyHouse{
        require(theHouse == msg.sender);
        _;
    }
    
    constructor() public{
        theHouse = msg.sender;
    }
    
    function gameRegistration(uint _gameCode)public payable{
        require(msg.value >= 1 ether);
        players memory temp = players(msg.sender,msg.value);
        if(_gameCode == 111){ // here players for coin flip are registered
            coinFlipPlayers[i] = temp;
            if(i == 1){
                require(coinFlipPlayers[0].amount == coinFlipPlayers[1].amount);
                emit startGame("Both players registered. Start the coinflip");
            }
            i++;
            coinFlipAmount = coinFlipAmount+msg.value;
        }
        else if(_gameCode == 222){ // here players for jackpot are registered
            jackpotPlayers.push(temp);
            if(j > 0){
                require(jackpotPlayers[0].amount == jackpotPlayers[j].amount);
                if(j == 10){
                    emit startGame("All players registered. Start the jackpot");
                }
            }
            j++;
            jackpotAmount = jackpotAmount+msg.value;
        }
        else{
            address invalid = msg.sender;
            invalid.transfer(msg.value);
            emit startGame("Invalid game code");
        }
    }
    
    function gameWinner(uint _playerNo, uint _gameCode) public onlyHouse returns(address _winner, uint _amount){
        if(_gameCode == 111){
            require(coinFlipAmount != 0);
            houseCommission = ((coinFlipAmount * 10)/100);
            uint cFlipWinningAmount = coinFlipAmount - houseCommission;
            address cFlipWinner = coinFlipPlayers[_playerNo].player;
            cFlipWinner.transfer(cFlipWinningAmount);
            theHouse.transfer(houseCommission);
            coinFlipAmount = 0;
            houseCommission = 0;
            return(cFlipWinner,cFlipWinningAmount);
        }
        else if(_gameCode == 222){
            require(jackpotAmount != 0);
            houseCommission = ((jackpotAmount * 10)/100);
            uint jPotWinningAmount = jackpotAmount - houseCommission;
            address jPotWinner = jackpotPlayers[_playerNo].player;
            jPotWinner.transfer(jPotWinningAmount);
            theHouse.transfer(houseCommission);
            jackpotAmount = 0;
            houseCommission = 0;
            return(jPotWinner,jPotWinningAmount);
        }
    }
}