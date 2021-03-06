pragma solidity ^0.4.21;
//pragma experimental ABIEncoderV2;

contract Cricket{
    
    enum matchResult {loose, win}
    enum Role {bat, ball, all, wk}
    
    address sponsor;
    address admin;
    address winningTeam;
    address loosingTeam;
    address manOfTheMatch;
    address teamFull;
    //uint8 i = 0;
      uint8 count;
    struct teamDetails{
        address playerAddress;
        bytes32 playerName;
        Role playerRole;
    }
        
    //Bowling statistics for a given bowler 
    struct bowlingStats{
        string bowlerName;
        uint overs;
        uint runsGiven;
        uint economy;
    }
    
    //Batting statistics for a given batsmen 
    struct battingStats{
        string batsmenName;
        uint totalRuns;
        uint totalBalls;
        uint strikeRate;
    }
    
    mapping(address => string) declaredResult;
    mapping(address => string) teamName;
    mapping(address => bowlingStats) bowlerDetails;
    mapping(address => battingStats) batsmenDetails;
    mapping(address => teamDetails[])team;
    //mapping(address => teamDetails[])teamB;
    
    event bowlerStats(address bowlerAddress);
    event batsmenStats(address batsmenAddress);
    
    //constructor to initialise sponsor
    function Cricket() public{
        sponsor = msg.sender;
    }
    
    //modifier to make sure only sponsor have access
    modifier onlySponsor{
        require(msg.sender == sponsor);
        _;
    }
    
    
    modifier onlySponsorOrAdmin(){
        require(msg.sender == sponsor||msg.sender == admin);
        _;
    }
        
        
    function assignAdmin(address _admin) public onlySponsor{
        admin = _admin;
    }
    
    function enterTeamName(address tAd,string tName) public onlySponsorOrAdmin{
        teamName[tAd] =  tName;
    }
    
    
    
    function addBowlerStats(address _bowlerAddress, string _bowlerName, uint _overs, uint _runsGiven, uint _economy) public onlySponsorOrAdmin {
        bowlerDetails[_bowlerAddress].bowlerName = _bowlerName;
        bowlerDetails[_bowlerAddress].overs = _overs;
        bowlerDetails[_bowlerAddress].runsGiven = _runsGiven;
        bowlerDetails[_bowlerAddress].economy = _economy;
        
        emit bowlerStats(_bowlerAddress);
    }
    
    function getBowlerStats(address _bowlerAddress) external view returns(string,uint,uint,uint) {
        bowlingStats storage bowler = bowlerDetails[_bowlerAddress];
        return (bowler.bowlerName,bowler.overs,bowler.runsGiven,bowler.economy);
    }
    
    function addBatsmenStats(address _batsmenAddress, string _batsmenName, uint _totalRuns, uint _totalBalls) public onlySponsorOrAdmin{
        batsmenDetails[_batsmenAddress].batsmenName = _batsmenName;
        batsmenDetails[_batsmenAddress].totalRuns = _totalRuns;
        batsmenDetails[_batsmenAddress].totalBalls = _totalBalls;
        batsmenDetails[_batsmenAddress].strikeRate = (_totalRuns/_totalBalls)*100;
        
        emit batsmenStats(_batsmenAddress);
    }
    
    function getBatsmenStats(address _batsmenAddress) external view returns(string,uint,uint,uint) {
        battingStats storage batsmen = batsmenDetails[_batsmenAddress];
        return (batsmen.batsmenName,batsmen.totalRuns,batsmen.totalBalls,batsmen.strikeRate);
    }
    
    function declareResults(address _winningTeam, address _loosingTeam, address _manOfTheMatch) public onlySponsorOrAdmin{
        winningTeam = _winningTeam;
        declaredResult[_winningTeam] = teamName[_winningTeam];
        loosingTeam = _loosingTeam;
        declaredResult[_loosingTeam] = teamName[_loosingTeam];
        manOfTheMatch = _manOfTheMatch;
        declaredResult[_manOfTheMatch] = batsmenDetails[_manOfTheMatch].batsmenName;
    }
    
    function getResults() external view returns(string,string,string){
        return(declaredResult[winningTeam],declaredResult[loosingTeam],declaredResult[manOfTheMatch]);
    }
    
    function enterTeamDetails(address _teamAddress,address _playerAddress, bytes32 _playerName, Role _playerRole) public onlySponsorOrAdmin returns(string,uint8){
       //uint8 i;
        if (count < 2 && teamFull != _teamAddress){
        teamDetails memory temp = teamDetails(_playerAddress,_playerName,_playerRole);    
        team[_teamAddress].push(temp);
        count++;
            if (count >=2){
            teamFull = _teamAddress;
            count = 0;
            return("All details successfully added",count);
            }
        return("Player details updated",count);
        }else{
            return("All players successfully entered for this team. Please change team address and enter new team",count);
        }
    }
    
    function getTeamDetails(address _teamAddress) public view returns(bytes32[2],Role[2]){
        uint8 c=0;
        bytes32[2] memory s;
        Role[2] memory r; 
        
        teamDetails[] storage teams = team[_teamAddress];
        
        for(c=0;c<2;c++){
            s[c] = teams[c].playerName;
            r[c] = teams[c].playerRole;
        }
        return(s,r);
    }
}


contract Payment is Cricket{
    
    uint8 pc;
    //uint256[] valueWin;
    //uint256[] valueLoose;
    
    function Payment() public payable {
        require(msg.value >= 100);
    }
    
    function payMoM(uint256 _value)public onlySponsorOrAdmin returns(string,uint256){
        manOfTheMatch.transfer(_value);
        return("manOfTheMatch payment completed",manOfTheMatch.balance);
    }
    
    function payWinningTeam(uint256 _valueWin)public onlySponsorOrAdmin returns(uint256){
        teamDetails[] storage teamWin = team[winningTeam]; 
        //valueWin[] = _valueWin[];
        for(pc=0;pc<2;pc++){
            uint256 vW = _valueWin;
            teamWin[pc].playerAddress.transfer(vW);
        }
        pc = 0;
        return(this.balance);
    }
    
    function payLoosingTeam(uint256[] _valueLoose)public onlySponsorOrAdmin returns(string){
        teamDetails[] storage teamLoose = team[loosingTeam]; 
        //valueLoose[] = _valueLoose[];
        for(pc=0;pc<2;pc++){
            uint256 vL = _valueLoose[pc];
            teamLoose[pc].playerAddress.transfer(vL);
        }
        pc = 0;
    }
}