pragma solidity ^0.4.23;

contract SimpleAuction{

    address admin;
    address[] bidders;
    
    uint topBid;
    uint topBdId;
    uint bdId;
    
    mapping(address => bool) bidderStatus;
    mapping(uint => bidDetails) bid;
    
    struct bidDetails{
        address bidderAddress;
        uint bidAmount;
        uint bidTimestamp;
        uint bidId;
    }
    
    event bidderReg(address _bidderAdd);
    event bidWinner(bidDetails _topBid);
    
    modifier onlyAdmin{
        require(msg.sender == admin);
        _;
    }
    
    modifier notAdmin{
        require(msg.sender != admin);
        _;
    }
    
    constructor() public {
        admin = msg.sender;
    }
    
    function submitRegistration() public notAdmin {
        address bdr = msg.sender;
        bidders.push(bdr);
        
        emit bidderReg(msg.sender);
    }

    function acceptBidder(address _bidderAdd) public onlyAdmin {
        bidderStatus[_bidderAdd] = true;
    }
    
    function submitBid(uint _bidAmount) public returns(string){
        if(bidderStatus[msg.sender] == true){
            bdId++;
            bidDetails memory temp = bidDetails(msg.sender,_bidAmount,now,bdId);
            bid[bdId] = temp;
            if(bdId ==1){
                topBid = _bidAmount;
                topBdId = bdId;
            }else if(_bidAmount > topBid){
                topBid = _bidAmount;
                topBdId = bdId;
            }
            return("Bid Accepted");
        }else{
            return("Biddder not registered/accepted");
        }
    }
    
    function completeAuction() public onlyAdmin{
        bidDetails memory temp = bidDetails(bid[topBdId].bidderAddress,bid[topBdId].bidAmount,bid[topBdId].bidTimestamp,bid[topBdId].bidId);
        emit bidWinner(temp);
    }
}