pragma solidity ^0.4.21;

contract IPLPredictions{
    
    address admin;
    address[] predictor;
    uint8 predictorsCount;
    string[] matchResult;
    uint8 maxMatchId;
    
    struct fixture{
        string teamA;
        string teamB;
        uint timeStamp;
    }
    
    mapping(uint8 => fixture) matchId;
    mapping(address => string[]) prediction;
    mapping(address => uint8) successCount;
    
    event matchDetailsUpdated(uint8 _matchId, string _teamA, string _teamB, uint _timeStamp);
    event matchResultUpdated(uint8 _matchId, string _winningTeam);
    
    modifier onlyAdmin(){
        if(msg.sender != admin){
             revert;
        }
             _;
    }
    
    function IPLPredictions() public{
        admin = msg.sender;
    }
    
    //Below function is used to enter all the match fixtures
    function enterMatchFixture(uint8 _matchId, string _teamA, string _teamB, uint _timeStamp) public onlyAdmin {
        matchId[_matchId].teamA = _teamA;
        matchId[_matchId].teamB = _teamB;
        matchId[_matchId].timeStamp = _timeStamp;
        
        if (_matchId > maxMatchId){
            maxMatchId = _matchId;
        }
        
        emit matchDetailsUpdated(_matchId,_teamA,_teamB,_timeStamp);
    }
    
    //Below function is used to enter the match result
    function enterMatchResult(uint8 _matchId, string _winningTeam) public onlyAdmin returns(string,uint8,string){
        if (keccak256(matchId[_matchId].teamA) == keccak256(_winningTeam)||keccak256(matchId[_matchId].teamB) == keccak256(_winningTeam)){
            matchResult[_matchId] = _winningTeam;
            return("Match result successfully updated:",_matchId,_winningTeam);
            emit matchResultUpdated(_matchId,_winningTeam);
        }
        else{
            return("Please enter correct match result",_matchId,"");
        }
    } 
    
    //Below function is used to view the match fixture for a given match id
    function getMatchFixture(uint8 _matchId) public view returns(string teamA,string teamB,uint mathTime){
        return(matchId[_matchId].teamA,matchId[_matchId].teamB,matchId[_matchId].timeStamp);
    }
    
    //Below function is used to view the match result for a given match id
    function getMatchResult(uint8 _matchId) public view returns(string winningTeam){
        return(matchResult[_matchId]);
    }
    
    // Predictor related functions are below
    //Below function is used to register the predictors. Admin cannot be a predictor
    function registerPredictor() public payable {
        require(msg.sender != admin && msg.value == 1 ether);
        predictor[predictorsCount] = msg.sender;
        predictorsCount++;
    }
    
    //Below function is used to make predictions by the registered predictor
    function makePrediction(uint8 _matchId, string _prediction) public returns(string){
        uint8 i = 0;
        uint8 check;
        for(i=0;i<predictorsCount;i++){
            if (predictor[i] == msg.sender){
                check = 1;
            }
        }
        if (check == 1 && (now <= matchId[_matchId].timeStamp - 2 hours) ){
            //predictions memory temp = predictions(_matchId,_prediction);
            //prediction[msg.sender].push(temp);
            prediction[msg.sender][_matchId] = _prediction; 
            return("prediction updated for given matchId");
        }
        else{
            return("invalid predictor or prediction time elapsed");
        }
    }
    
    //A registered predictor can view the total successfull predictions done by them with below function
    function countValidPredictions() public view returns(uint8){
        uint8 mId;
        uint8 correctPredict = 0;
        for(mId=0;mId<maxMatchId;mId++){
            if (keccak256(prediction[msg.sender][mId]) == keccak256(matchResult[mId])){
                correctPredict++;
            }
        }
        return(correctPredict);
    }
    
    function finalCounts() public onlyAdmin{
        uint8 pc;
        for(pc=0;pc<=predictorsCount;pc++){
            uint8 mId;
            uint8 correctPredict = 0;
            for(mId=0;mId<maxMatchId;mId++){
                if (keccak256(prediction[msg.sender][mId]) == keccak256(matchResult[mId])){
                    correctPredict++;
                }
            }
        successCount[predictor[pc]] = correctPredict;    
        }
    }
}