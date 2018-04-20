pragma solidity ^0.4.22;

/* This is the POC for the supplychain where the retailers can register and place orders for the goods.
   Here in this example, we are taking the manufacturer as Samsung. Here Samsung is used as example. This can be 
   used by any company*/
   
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
    
    function retailerAccept(uint _rCount, uint _rCred) public onlyAdmin {
        address rAd = retailers[_rCount].retailerAddress;
        retailerAcceptance[rAd] = true;
        retailers[_rCount].credibility = retailerCredibility(_rCred);
        emit retailerAccepted("Retailer is accepted with detials",retailers[_rCount].name,retailers[_rCount].retailerAddress,retailerCredibility(_rCred));
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

contract Orders is Retailers{
    
    enum Item {TV,Refregirator,HomeTheater,AirConditioner,Microwave}
    uint[] pricePerUnit = [2000 wei,1000 wei,1000 wei,2000 wei,1000 wei];
    
    uint units;
    uint discount;
    uint set;
    uint orderNumber;
    
    address admin;
    
    struct order{
        address rAdd;
        Item item;
        uint quantity;
        uint orderAmount;
    }
    
    mapping(uint => order) orders;
    
    event retailerOrder(address _retailersAddress,Item orderedItem, uint totalUnits,uint amountPaid);
    
    modifier onlyAdmin(){
        require(admin == msg.sender);
        _;
    }
    
    function Orders() public{
        admin = msg.sender;
        samsungAdmin = admin;
    }
    
    function placeOrder(uint _item, uint _units) public payable{
        orderNumber++;
        order memory temp = order(msg.sender,Item(_item),_units,msg.value);
        orders[orderNumber] = temp;
        //emit retailerOrder(msg.sender,orderedItem,_units,amountPayable);
    }
    
    function executeOrder(uint _orderNumber,address _companyAddress) public onlyAdmin returns(string){
        uint finalPayable;
        uint totalUnits = orders[_orderNumber].quantity;
        uint price = pricePerUnit[uint(orders[_orderNumber].item)];
        uint amountPayable = price * totalUnits;
        uint amountPaid = orders[_orderNumber].orderAmount;
        address orderRAdd = orders[_orderNumber].rAdd;
        uint retailerCheck;
        retailerCredibility rCred;
        retailerCheck = checkRetailerExistance(orders[_orderNumber].rAdd);
        if(retailerCheck != 0){
            rCred = retailers[retailerCheck].credibility;
        }else{
            return("Retailer is not listed");
        }
        if(uint(rCred) == 0){
            return("Retailer not yet accepted, contact admin");
        }else if(uint(rCred) == 1){
            orderPayment(amountPaid,amountPayable,_companyAddress,orderRAdd,_orderNumber);
        }else if(uint(rCred) == 2){
            if(totalUnits > 10000){
                finalPayable = (amountPayable * 90)/100;
                orderPayment(amountPaid,finalPayable,_companyAddress,orderRAdd,_orderNumber);
            }else{
                orderPayment(amountPaid,amountPayable,_companyAddress,orderRAdd,_orderNumber);
            }
        }else if(uint(rCred) == 3){
            if(totalUnits > 10000){
                finalPayable = (amountPayable * 80)/100;
                orderPayment(amountPaid,finalPayable,_companyAddress,orderRAdd,_orderNumber);
            }else if(totalUnits > 5000 && totalUnits <= 10000){
                finalPayable = (amountPayable * 90)/100;
                orderPayment(amountPaid,finalPayable,_companyAddress,orderRAdd,_orderNumber);
            }else{
                orderPayment(amountPaid,amountPayable,_companyAddress,orderRAdd,_orderNumber);
            }
        }else if(uint(rCred) == 4){
            if(totalUnits > 10000){
                finalPayable = (amountPayable * 70)/100;
                orderPayment(amountPaid,finalPayable,_companyAddress,orderRAdd,_orderNumber);
            }else if(totalUnits > 5000 && totalUnits <= 10000){
                finalPayable = (amountPayable * 85)/100;
                orderPayment(amountPaid,finalPayable,_companyAddress,orderRAdd,_orderNumber);
            }else{
                orderPayment(amountPaid,amountPayable,_companyAddress,orderRAdd,_orderNumber);
            }
        }
    }
    
    function orderPayment(uint _paid,uint _payable, address _comAd, address _orAd, uint _orNo) internal onlyAdmin returns(string){
        if(_paid >= _payable){
            _comAd.transfer(_payable);
            return("Order Executed");
            }else{
                _orAd.transfer(_paid);
                orders[_orNo].orderAmount = 0;
                return("Insufficient ammount, hence returning amount and canceling order");
            }
    }
}