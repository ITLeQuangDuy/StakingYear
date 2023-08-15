// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDTToken is ERC20, Ownable {
    constructor() ERC20("USDTToken", "USDT") {}

    function mint(address account, uint256 amount) public onlyOwner{
        _mint(account, amount);
    }

    function burn(uint256 amount) public onlyOwner{
        _burn(msg.sender, amount);
    }
}