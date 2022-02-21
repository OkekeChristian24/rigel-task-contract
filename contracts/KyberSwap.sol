
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

// import "./helpers/Ownable.sol";
// import "./helpers/SafeMath.sol";
// import "./helpers/IERC20.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/**
 * @title KyberSwap
 * @dev KyberSwap is a base contract for managing a token trade,
 * allowing traders to trade between a custom token and ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for trading tokens, and conform
 * the base architecture for trades. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of token trades. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract KyberSwap is Ownable{
  using SafeMath for uint256;

    // trading rate
    uint256 public ethToERC20Rate;

    // token interface
    IERC20 public token;
    
  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param weiSpent weis paid for purchase
   * @param tokenReceived amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 weiSpent,
    uint256 tokenReceived
  );

  
  /**
   * Event for eth purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param weiReceived weis paid purchased
   * @param tokenSpent amount of tokens for purchase
   */
  event EthPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 weiReceived,
    uint256 tokenSpent
  );

  /**
   * Event for token address change logging
   * @param newAddress New token address
   */
  event TokenChange(
    address indexed newAddress
  );

  /**
  * Event for trade rate logging
  * @param newRate New trade rate
   */
  event RateChange(
      uint256 newRate
  );

  constructor(uint256 _ethToERC20Rate, address tokenAddress) public {
    // token = IBEP20(_tokenAddress);
    ethToERC20Rate = _ethToERC20Rate;
    token = IERC20(tokenAddress);
  }

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  receive() external payable {
    
    // process the token purchase
    swapEthForERC20(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function swapEthForERC20(address payable _beneficiary) public payable {
    require(msg.value > 0, "swapEthForBEP20: Sent value must be greater than zero");
    require(_beneficiary != address(0), "swapEthForBEP20: Purchasing address can NOT be zero address");
    uint256 weiAmount = msg.value;
    

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);
    
    // update state
    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );
  }

  
  
  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param trader Address performing the token purchase
   * @param _tokenAmt amount of token spent for the purchase
   */
  function swapERC20ForEth(address payable trader, uint256 _tokenAmt) public{
    require(_tokenAmt > 0, "swapERC20ForEth: Token amount must be greater than zero");
    require(trader != address(0), "swapEthForBEP20: Trader address can NOT be zero address");
    
    // Transfer token from trader to smart contract
    token.transferFrom(trader, address(this), _tokenAmt);

    // transfer Eth from the smart contract to the trader
    trader.transfer(_tokenAmt.div(ethToERC20Rate));

    emit EthPurchase(
      trader,
      trader,
      _tokenAmt,
      _tokenAmt.div(ethToERC20Rate)
    );

  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal{
        
    token.transfer(_beneficiary, _tokenAmount);
  }
    

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
     uint256 tokenAmt = _weiAmount.mul(ethToERC20Rate);    
    
    return tokenAmt;
  }

  function withdrawAllTokens(address addr) public onlyOwner{
      require(addr != address(0), "WithdrawAllTokens: Withdrawal address can not be zero");
      token.transfer(addr, token.balanceOf(address(this)));
  }
  
  function WithdrawAllEth(address payable addr) public onlyOwner{
      require(addr != address(0), "WithdrawAllEth: Withdrawal address can not be zero");
      addr.transfer(address(this).balance);
  }


    /**
    * @dev Returns the rate for trading eth to ERC20 token.
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
  function getEthToERC20Rate() public view returns(uint256){
    return ethToERC20Rate;
  }

  /**
  * @dev Sets a new token for trading
  * @param _newTokenAddress Address for the new token
   */
  function setToken(address _newTokenAddress) public onlyOwner {
      require(_newTokenAddress != address(0), "setToken: Token address can NOT be zero address");
      token = IERC20(_newTokenAddress);
      emit TokenChange(_newTokenAddress);
  }

  /**
  * @dev Sets a new rate for trading
  * @param _ethToERC20Rate Address for the new token
   */
  function setEthToERC20Rate(uint256 _ethToERC20Rate) public onlyOwner {
      require(_ethToERC20Rate != 0, "setEthToERC20Rate: Token rate can NOT be zero");
      ethToERC20Rate = _ethToERC20Rate;
      emit RateChange(_ethToERC20Rate);
  }
  

}