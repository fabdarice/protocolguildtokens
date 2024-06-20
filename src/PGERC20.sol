// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract PGERC20 is ERC20 {
    address internal constant PG_ADDRESS = 0x25941dC771bB64514Fc8abBce970307Fb9d477e9;

    uint256 public immutable startVesting;
    uint256 public immutable vestingDuration;
    uint256 public immutable vestingAllocation;
    uint256 public releasedAmount;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply)
        ERC20(_name, _symbol, _decimals)
    {
        vestingAllocation = _totalSupply / 100;
        startVesting = block.timestamp;
        vestingDuration = 365 days * 4;
        _mint(address(this), vestingAllocation);
        _mint(msg.sender, _totalSupply - vestingAllocation);
    }

    function releasable() public view returns (uint256) {
        return vestedAmount() - releasedAmount;
    }

    function release() public virtual {
        uint256 amount = releasable();
        releasedAmount += amount;

        if (amount > 0) transfer(PG_ADDRESS, amount);
    }

    function vestedAmount() public view returns (uint256) {
        if (block.timestamp >= (startVesting + vestingDuration)) {
            return vestingAllocation;
        } else {
            return (vestingAllocation * (block.timestamp - startVesting)) / vestingDuration;
        }
    }
}
