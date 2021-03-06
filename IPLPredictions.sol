pragma solidity ^0.4.21;

contract IPLPredictions{
    
    //Fantasy Predictions Challenge
    
    /*This code is for a fantasy predictions challenge. Once the contract is deployed by admin, 
    any member can register as a predictor by paying 1 ether, and give the predictions.  
    At end of the tournament, admin can check the final counts and pay top predictors directly from contract. */
    
    address admin;
    //address[] predictor;
    uint predictorsCount;
    //string[] matchResult;
    uint maxMatchId;
    uint tpc;
    
    struct fixture{
        string teamA;
        string teamB;
        uint timeStamp;
    }
    
    mapping(uint => fixture) matchId;
    //mapping(address => string[]) prediction;
    mapping(address => mapping(uint => string)) prediction;
    mapping(address => uint) successCount;
    mapping(uint => string) matchResult;
    mapping(uint => address) predictor;
    mapping(uint => address) toppers;
    
    event matchDetailsUpdated(uint _matchId, string _teamA, string _teamB, uint _timeStamp);
    event matchResultUpdated(uint _matchId, string _winningTeam);
    event finalPredictionCounts(address _predictor,uint _totalCorrectPredictions);
    event winner(address _predictor,uint _amountWon);
    
    modifier onlyAdmin(){
        require(msg.sender == admin);
             _;
    }
    
    function IPLPredictions() public{
        admin = msg.sender;
    }
    
    //Below function is used to enter all the match fixtures
    function enterMatchFixture(uint _matchId, string _teamA, string _teamB, uint _timeStamp) public onlyAdmin {
        matchId[_matchId].teamA = _teamA;
        matchId[_matchId].teamB = _teamB;
        matchId[_matchId].timeStamp = _timeStamp;
        
        if (_matchId > maxMatchId){
            maxMatchId = _matchId;
        }
        
        emit matchDetailsUpdated(_matchId,_teamA,_teamB,_timeStamp);
    }
    
    //Below function is used to enter the match result
    function enterMatchResult(uint _matchId, string _winningTeam) public onlyAdmin returns(string,uint,string){
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
    function getMatchFixture(uint _matchId) public view returns(string teamA,string teamB,uint mathTime){
        return(matchId[_matchId].teamA,matchId[_matchId].teamB,matchId[_matchId].timeStamp);
    }
    
    //Below function is used to view the match result for a given match id
    function getMatchResult(uint _matchId) public view returns(string winningTeam){
        return(matchResult[_matchId]);
    }
    
    // Predictor related functions are below
    //Below function is used to register the predictors. Admin cannot be a predictor
    function registerPredictor() public payable {
        require(msg.sender != admin && msg.value == 1 ether);
        predictor[predictorsCount] = msg.sender;
        predictorsCount++;
    }
    
    //Below function is used to verify if it is valid predictor
    function checkPredictor(address _predictor) internal view returns(uint8){
        uint i = 0;
        uint8 check;
        for(i=0;i<predictorsCount;i++){
            if (predictor[i] == _predictor){
                check = 1;
            }
        }
        return(check);
    }
    
    //Below function is used to make predictions by the registered predictor
    function makePrediction(uint _matchId, string _prediction) public returns(string){
        uint8 check;
        check = checkPredictor(msg.sender);
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
    function countValidPredictions() public view returns(uint totalValidPredictions){
        uint mId;
        uint correctPredict = 0;
        uint8 check;
        check = checkPredictor(msg.sender);
        if(check == 1){
            for(mId=0;mId<=maxMatchId;mId++){
                if (keccak256(prediction[msg.sender][mId]) == keccak256(matchResult[mId])){
                    correctPredict++;
                }
            }
        }
        return(correctPredict);
    }
    
    function finalCounts() public onlyAdmin{
        uint pc;
        for(pc=0;pc<predictorsCount;pc++){
            uint mId1;
            uint correctPredict = 0;
            for(mId1=0;mId1<=maxMatchId;mId1++){
                if (keccak256(prediction[predictor[pc]][mId1]) == keccak256(matchResult[mId1])){
                    correctPredict++;
                }
            }
            successCount[predictor[pc]] = correctPredict;  
            emit finalPredictionCounts(predictor[pc],successCount[predictor[pc]]);
        }
    }
    
    function topPredictor() public onlyAdmin returns(uint _totalTopPredictors, uint _totalAmount){
        uint pc1;
        uint topCount;
        uint tp;
        uint tpc1;
        uint incount;
        for(pc1=0;pc1<=predictorsCount;pc1++){
            incount = successCount[predictor[pc1]];
            if(incount > topCount){
                topCount = incount;
            }
        }
        for(tp=0;tp<=predictorsCount;tp++){
            if(topCount == successCount[predictor[tp]]){
                toppers[tpc1] = predictor[tp];
                tpc1++;
            }
        }
        tpc = tpc1;
        return(tpc,this.balance);
    }
    
    function winnerPayment()public payable onlyAdmin{
        uint tp1;
        uint totalAmount = this.balance;
        uint winAmount;
        winAmount = (totalAmount/tpc);
        for(tp1=0;tp1<tpc;tp1++){
            toppers[tp1].transfer(winAmount);
            emit winner(toppers[tp1],winAmount);
        }
    }
}