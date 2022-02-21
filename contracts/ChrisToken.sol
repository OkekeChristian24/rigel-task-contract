// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ChrisToken is ERC20{
    constructor() ERC20("Chris Token", "CHRIS") public {
        _mint(msg.sender, 100000000000000000000000000);
    }
}