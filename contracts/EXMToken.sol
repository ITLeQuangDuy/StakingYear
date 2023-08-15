// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EXMToken is ERC20, Ownable{
    constructor() ERC20("Example Token", "EXM"){}

    function mint(address account, uint256 amount) public onlyOwner{
        _mint(account, amount);
    }

    function burn(uint256 amount) public onlyOwner{
        _burn(msg.sender, amount);
    }

    /*
     ____    _____   __  __   ___  __  __   ___   ____    _____ 
    |  _ \  | ____| |  \/  | |_ _| \ \/ /  |_ _| |  _ \  | ____|
    | |_) | |  _|   | |\/| |  | |   \  /    | |  | | | | |  _|  
    |  _ <  | |___  | |  | |  | |   /  \    | |  | |_| | | |___ 
    |_| \_\ |_____| |_|  |_| |___| /_/\_\  |___| |____/  |_____|    
     
     _       _____ 
    | |     | ____|
    | |     |  _|
    | |____ | |___  
    |______||_____|
    */
}