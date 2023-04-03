// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./demoTokens.sol";

contract Vote {

    DemoToken tkn = new DemoToken();

    function print()public view returns(string memory _data){
        _data = tkn.printData();
    }
}
