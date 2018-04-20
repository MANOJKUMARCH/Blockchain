pragma solidity ^0.4.22;

/* This is the POC for the supplychain where the retailers can register and place orders for the goods.
   Here in this example, we are taking the manufacturer as Samsung*/
   
contract Retailers{
    
    uint retailerCount;
    address samsungAdmin;
    
    enum retailerCredibility {requested,poor,good,fair,best}
    
    mapping(address => bool) retailerAcceptance;
    mapping(uint => retailerDetails) retailers;
    
    struct retailerDetails{
        string name;
        address retailerAddress;
        retailerCredibility credibility;
    }
    
    event retailerRequets(string _rName,address _rAddress,uint _rCred);
    event retailerAccepted(string,string _rName, address _rAddress, retailerCredibility);
    
    modifier onlyAdmin(){
        require(msg.sender == samsungAdmin);
        _;
    }
    
    modifier notAdmin(){
        require(msg.sender != samsungAdmin);
        _;
    }
    
    function Retailers() public{
    samsungAdmin = msg.sender;
    }
    
    function checkRetailerExistance(address _rAddress) public view returns(uint _check){
        uint i=0;
        uint check;
        for(i=0;i<=retailerCount;i++){
            if(retailers[i].retailerAddress == _rAddress){
                check = i;
                return(check);
            }
        }
        return(check);
    }
    
    function retailerRegister(string _name, retailerCredibility _rC) public notAdmin{
        uint check1 = checkRetailerExistance(msg.sender);
        if(check1 == 0){
            retailerDetails memory temp = retailerDetails(_name,msg.sender,_rC);
            retailerCount++;
            retailers[retailerCount] = temp;
            emit retailerRequets(_name,msg.sender,retailerCount);
        }
    }
    
    function retailerAccept(uint _rCount, retailerCredibility _rCred) public onlyAdmin {
        address rAd = retailers[_rCount].retailerAddress;
        retailerAcceptance[rAd] = true;
        retailers[_rCount].credibility = _rCred;
        emit retailerAccepted("Retailer is accepted with detials",retailers[_rCount].name,retailers[_rCount].retailerAddress,_rCred);
    }
    
    function getRetailerDetails(address _rAddress) external view returns(string _name, address _rAd, retailerCredibility){
        uint check2 = checkRetailerExistance(msg.sender);
        if(check2 == 0){
                return(retailers[check2].name,retailers[check2].retailerAddress,retailers[check2].credibility);
        }
        retailerCredibility inv;
        return("Invalid retailer Address",_rAddress,inv);
    }
}

contract Orders{
    
    enum item {TV,Refregirator,HomeTheater,AirConditioner,Microwave}
    
    uint units;
    uint discount;
    
    Retailers retailer;
    
    function checkValidRetailer(address _retailersContractAddress) public{
        retailer = Retailers(_retailersContractAddress);
        uint retailerCheck;
        retailerCheck = retailer.checkRetailerExistance(msg.sender);
        require(retailerCheck != 0);
    }
}