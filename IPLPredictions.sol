pragma solidity ^0.4.21;

contract IPLPredictions{
    
    address admin;
    
    struct fixture{
        //uint8 matchId;
        string teamA;
        string teamB;
        uint timeStamp;
    }
    
    mapping(uint8 => fixture) matchId;
    mapping(uint8 => string) matchResult;
    
    event matchDetailsUpdated(uint8 _matchId, string _teamA, string _teamB, uint _timeStamp);
    event matchResultUpdated(uint8 _matchId, string _winningTeam);
    
    modifier onlyAdmin(){
        if(msg.sender != admin){
             revert;
        }
             _;
    }
    
    function IPLPredictions(){
        admin = msg.sender;
    }
    
    function enterMatchFixture(uint8 _matchId, string _teamA, string _teamB, uint _timeStamp) onlyAdmin /*returns(string,string,uint,uint)*/{
        matchId[_matchId].teamA = _teamA;
        matchId[_matchId].teamB = _teamB;
        matchId[_matchId].timeStamp = _timeStamp;
        
        emit matchDetailsUpdated(_matchId,_teamA,_teamB,_timeStamp);
    }
    
    function enterMatchResult(uint8 _matchId, string _winningTeam) onlyAdmin returns(string,uint8,string){
        if (keccak256(matchId[_matchId].teamA) == keccak256(_winningTeam)||keccak256(matchId[_matchId].teamB) == keccak256(_winningTeam)){
            matchResult[_matchId] = _winningTeam;
            return("Match result successfully updated:",_matchId,_winningTeam);
           // emit matchResult(_matchId,_winningTeam);
        }
        else{
            return("Please enter correct match result",_matchId,"");
        }
    } 
    
    function getMatchFixture(uint8 _matchId) view returns(string teamA,string teamB,uint mathTime){
        return(matchId[_matchId].teamA,matchId[_matchId].teamB,matchId[_matchId].timeStamp);
    }
    
    function getMatchResult(uint8 _matchId) view returns(string winningTeam){
        return(matchResult[_matchId]);
    }
}