pragma solidity^0.4.24;

contract Token{
    //function totalSupply() constant returns(uint supply){}
    uint totalSupply;
    
    function balanceOf(address _owner) constant returns(uint balance){}
    
    function transfer(address _to, uint _value) returns (bool success){}
    
    function transferFrom(address _from, address _to, uint _value) returns (bool success){}
    
    function approve(address _spender, uint _value) returns (bool success){}
    
    function allowance(address _owner, address _spender) returns(uint remaining){}
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract StandardToken is Token{
    
    uint public totalSupply;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    
    
    function transfer(address _to, uint _value) returns(bool success){
        
        if (balances[msg.sender] >= _value && _value > 0 && balances[_to]+_value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }else{
            return false;
        }
    }
    
    function transferFrom(address _from, address _to, uint _value) returns(bool success){
        if (balances[_from] >= _value && _value > 0 && allowed[_from][msg.sender] >= _value && balances[_to]+_value >= balances[_to]) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        }else{
            return false;
        }
    }
    
    function balanceOf(address _owner) constant returns(uint balance){
        return balances[_owner];
    }
    
    function approve(address _spender, uint _value) returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) returns(uint remaining){
        return allowed[_owner][_spender];
    }
}

contract ManCoin is StandardToken{
    
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'M0.1';
    
    function()public{
        throw;
    }
    
    constructor() public{
        balances[msg.sender] = 1000000000000;
        totalSupply = 1000000000000;
        name = 'ManCoin';
        symbol = 'MCN';
        decimals = 6;
    }
}