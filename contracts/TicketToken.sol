pragma solidity 0.4.15;

import './ERC20.sol';
import './SafeMath.sol';

contract TicketToken is ERC20 {
    
    using SafeMath for uint256;
    
    uint public constant _totalSupply = 0;

    string public symbol;
    string public name;
    uint256 public price;
    uint8 public constant decimals = 0;

    address public owner;

    mapping(address => uint256) tickets;
    
    // who is giving permission => (who is given permission to spend funds => how much allowed to spend)
    mapping(address => mapping(address => uint256)) approved;
    
    // callback function, so that people can directly send money to contract address
    function () payable {
        buyTickets();
    }

    function TicketToken(string _name, string _symbol, uint256 _price) {
        owner = msg.sender;
        tickets[owner] = 100;
        name = _name;
        symbol = _symbol;
        price = _price;
    }
    
    function buyTickets() payable {
        require(msg.value > 0);
        if(msg.value < price) {
            throw;
        } else {
            // msg.sender.send(msg.value - _price)
            transferFromOwnerToSender(1, msg.sender);
        }
        owner.transfer(msg.value);
    }
    
    function transferFromOwnerToSender(uint _amountOfTickets, address _sender) {
        tickets[owner] = tickets[owner].sub(_amountOfTickets);
        tickets[_sender] = tickets[_sender].add(_amountOfTickets);
    }

    function totalSupply() constant returns (uint _totalSupply) {
        return _totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return tickets[_owner];
    }

    function sellTickets(address _to, uint _numberOfTickets) payable returns (bool) {
        require(
            tickets[msg.sender] > 0 &&
            tickets[msg.sender] > _numberOfTickets &&
            _to.balance > (_numberOfTickets * price)
        );
        tickets[msg.sender] = tickets[msg.sender].sub(_numberOfTickets);
        uint256 myValue = msg.value;
        myValue.add(price * _numberOfTickets);
        tickets[_to] = tickets[_to].add(_numberOfTickets);
        uint256 toBalance = _to.balance;
        toBalance -= (price * _numberOfTickets);
        return true;
    }

    function buyTickets(address _from, uint _numberOfTickets) payable returns (bool) {
        require(
            tickets[_from] > 0 &&
            tickets[_from] > _numberOfTickets &&
            msg.value > (_numberOfTickets * price)
        );
        uint256 myValue = msg.value;
        myValue = myValue.sub(price * _numberOfTickets);
        tickets[msg.sender] = tickets[msg.sender].add(_numberOfTickets);
        tickets[_from] = tickets[_from].sub(_numberOfTickets);
        uint256 fromBalance = _from.balance;
        fromBalance += (price * _numberOfTickets);
        return true;
    }

    function transfer(address _to, uint _value) returns (bool success) {
        // require will throw an exception if any conditions inside fail
        require(
            tickets[msg.sender] >= _value &&
            _value > 0 
        );
        tickets[msg.sender] = tickets[msg.sender].sub(_value);
        tickets[_to] = tickets[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        require(
            approved[_from][msg.sender] >= _value &&
            tickets[msg.sender] > _value &&
            _value > 0
        );
        tickets[_from] = tickets[msg.sender].sub(_value);
        tickets[_to] = tickets[msg.sender].add(_value);
        // lower the total amount allowed to spend
        approved[_from][msg.sender] = approved[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) returns (bool success) {
        approved[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return approved[_owner][_spender];
    }
} 