// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DemoToken is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("DemoToken", "DTK") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public  {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function printData()public pure returns(string memory){
        return "Hello";
    }
}

// setWardensPerThousandMember(int) : this will define number of wardens a community can have per 1K members
// currentWardenCount(categoryID): get Current Warden count for category
// MemberCapacity: total community members /  setWardensPerThousandMember
// becomeWarden(stackAmount, categoryId) - Check if user is whitelisted, Check if currentWardenCount < memberCapacity
// removeWarden(walletAddress, categoryId) - Remove warden of particular category - Only Owner / Contract Only
// resign(categoryId) : will unstake the tokens and user will be removed from warden position
// isWarden(walletAddress) : will check if user is warden
// setRewardPerBlock : Only Owner
// setMiniumStakeAmount - Only Owner
// updateWardens :  for all categories check if currentWardenCount > memberCapacity, then remove the last warden