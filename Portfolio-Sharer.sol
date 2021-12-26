// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CoinHodler is ERC20,Ownable {
    constructor() ERC20("Coin Hodler", "HODLHODL") {
        _mint(msg.sender, 21e27);
    }

    function add(address token) public onlyOwner {
        require(coins.length<50, "must be less than 50 coins");
        coins.push(token);
    }

    address[] public coins; 

    function burn(uint amount) public virtual {
        _burn(msg.sender,amount);
        
        for(uint i = 0;i<coins.length;i++){
            disburse(msg.sender,coins[i],amount);
        }
    }

    function disburse(address to, address token, uint amountBurned) internal virtual{
        ERC20(token).transfer(to,getAmountToDisburse(amountBurned,token));
    }

    function getAmountToDisburse(uint amountBurned, address token) public view returns(uint amount){
        uint balance = ERC20(token).balanceOf(address(this));
        amount = amountBurned*balance/totalSupply();
    }
}

contract CoinHodler2 is CoinHodler{

    mapping (address=>mapping(address=>uint)) public creditsUsed;

    mapping (address=>uint) public tokensBurnt; 

    function burn(uint amount) public override {
        _burn(msg.sender,amount);
        tokensBurnt[msg.sender] += amount;
        
        for(uint i = 0;i<coins.length;i++){
            disburse(msg.sender,coins[i],amount);
        }
    }

    function disburse(address to, address token, uint amountBurned) internal override{
        ERC20(token).transfer(to,getAmountToDisburse(amountBurned,token));
        creditsUsed[msg.sender][token]+=amountBurned;
    }

    function get(address token) public{
        uint amountToGet = tokensBurnt[msg.sender] - creditsUsed[msg.sender][token];
        ERC20(token).transfer(msg.sender, amountToGet);
        creditsUsed[msg.sender][token]+= amountToGet;
    }
}

