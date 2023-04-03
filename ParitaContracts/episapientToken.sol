// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EpisapientToken is ERC20, Ownable{
    
    ERC20 public usdc;
    uint256 public tokenPrice; // current token price in USDC
    address payable public PlatformFeeAddress; // address to which platform fees are sent
    uint256 public feeAmount; // current amount of platform fees in USDC
    address public TreasuryPool = 0xafb924b42C7A1fBA26657569a290dBf05dE42F08; // address of TreasuryPool
    address public SDAMPool = 0x4489D76D66112328b227FA7E77B835dA571bb993; // address of SDAMPool
    address public CharityPool = 0x3DbBb9FE57138bD7D16B1FEb69D6d2EeB9e36f00; // address of CharityPool
    
    struct PlatformFee {
        string feeType; // type of platform fee
        uint256 amount; // amount of platform fee in USDC
    }

    struct Tokenomics{
        string Type; // type of tokenomics (e.g. "burn")
        uint256 Percentage; // percentage of total supply affected by tokenomics
    }

    mapping(string => PlatformFee) public platformfee; // mapping of platform fees by type
    mapping(string => Tokenomics) public tokenomics; // mapping of tokenomics by type

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender,4200000000*(10**18)); // mint initial supply to contract creator
        tokenPrice = 10**16; // set initial token price to 0.01 USDC
    }

    function setPeggedTokenAddress(address _usdcaddress) public onlyOwner {
        usdc = ERC20(_usdcaddress); // set address of the USDC token contract
    }

    function calculateUsdcperTokenAmount(uint256 usdcAmount) public view returns(uint256) {
        uint256 tokenAmount = usdcAmount * tokenPrice / 10**18; // calculate token amount from USDC amount
        return tokenAmount; // return token amount
    }
    
    function calculateTokenPerUsdcAmount(uint256 tokenAmount) public view returns(uint256) {
        uint256 usdcAmount = tokenAmount * 10**18 / tokenPrice; // calculate USDC amount from token amount
        return usdcAmount; // return USDC amount
    }

    // This function is used to set the address where platform fees will be sent to
    function setPlatformFeeAddress(address payable _PlatformFeeAddress) public onlyOwner {
        PlatformFeeAddress = _PlatformFeeAddress;
    }

    // This function is used to set the platform fees
    function setPlatformFee(string memory feeType, uint256 amount) public onlyOwner {
        // Ensure that the fee amount is not negative
        require(amount >= 0, "Fee amount cannot be negative");
        // Create a new PlatformFee struct with the specified feeType and amount
        PlatformFee memory newFee = PlatformFee(feeType, amount);
        // Set the fee for the specified feeType in the platformfee mapping
        platformfee[feeType] = newFee;
    }

   // This function is used to set the tokenomics (i.e., the distribution of tokens)
    function setTokenomics(string memory Type, uint256 percentage) public onlyOwner{
        // Ensure that the percentage is less than or equal to 100
        require(percentage <= 100, "Percentage is less than 100");
        // Calculate the amount of tokens to be allocated based on the percentage
        uint256 Amount = (totalSupply()*percentage)/100;
        // Create a new Tokenomics struct with the specified Type and Amount
        Tokenomics memory newTokenomics = Tokenomics(Type, Amount); 
        // Set the tokenomics for the specified Type in the tokenomics mapping
        tokenomics[Type] = newTokenomics;
    }
}