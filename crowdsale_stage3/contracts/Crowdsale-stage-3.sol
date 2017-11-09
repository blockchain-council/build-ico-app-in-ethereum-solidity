pragma solidity ^0.4.16;

contract token {
	function transfer(address receiver, uint amount) public ;
	function mintToken(address target, uint mintedAmount) public ;
}

contract Crowdsale {

	enum State{
		Fundraising,
		Failed,
		Successful,
		Closed
	}

	State public state = State.Fundraising;

	struct Contribution {
		uint amount;
		address contributor;
	}

	Contribution[] contributions;


	uint public totalRaised;
	uint public currentBalance;
	uint public deadline;
	uint public completedAt;
	uint public priceInWei;
	uint public fundingMinimumTargetInWei;
	uint public fundingMaximumTargetInwei;
	address public creator;
	address public beneficiary;
	string public campaignUrl;
	byte constant version = "1";


	token public tokenReward;

	event LogFundingReceived(address addr, uint amoun, uint currentTotal);
	event LogWinnerPaid(address WinnerAddress);
	event LogFundingSuccessful(uint totalRaised);
	event LogFunderInitialized(address creator, address beneficiary, string url, uint _funddingMaximumTargetInEther, uint256 deadline);

	modifier inState(State _state){
		require(state == _state) ;

		_;
	}

	modifier isMinimum() {
		require(msg.value > priceInWei) ;
		_;
	}

	modifier iinMultipleOfPrice() {
		require(msg.value%priceInWei == 0) ;
		_;
	}

	modifier isCreator(){
		require(msg.sender == creator) ;
		_;
	}

	modifier atEndofLifecycle(){
		require(((state == State.Failed || state == State.Successful) && completedAt + 1 hours < now)) ;
		_;
	}

	function Crowdsale(
		uint _timeInMinutesForFundraising,
		string _campaignUrl,
		address _ifSuccessfulSendTo,
		uint256 _fundingMaximumTargetInEther,
		uint256 _funddingMinimumTargetInEther,
		token _addressOfTokenUsedAsReward,
		uint _etherCostOfEachToken
		) public {
		creator = msg.sender;
		beneficiary = _ifSuccessfulSendTo;
		campaignUrl = _campaignUrl;
		fundingMaximumTargetInwei = _fundingMaximumTargetInEther * 1 ether; 
		fundingMinimumTargetInWei = _funddingMinimumTargetInEther * 1 ether;
		deadline = now + (_timeInMinutesForFundraising * 1 minutes);
		currentBalance = 0;
		tokenReward = token(_addressOfTokenUsedAsReward);
		priceInWei = _etherCostOfEachToken * 1 ether;

		LogFunderInitialized(creator, beneficiary, campaignUrl, fundingMaximumTargetInwei, deadline);
	}

	function contribute()
	public 
	inState(State.Fundraising)
	isMinimum()
	iinMultipleOfPrice() payable returns (uint256){
		
		uint256 amountInWei = msg.value;

		contributions.push(
			Contribution({amount: msg.value, contributor: msg.sender})
			);
		totalRaised += msg.value;
		currentBalance = totalRaised;
		if(fundingMaximumTargetInwei !=0){
			tokenReward.transfer(msg.sender, amountInWei/priceInWei);
		}
		else{
			tokenReward.mintToken(msg.sender, amountInWei/priceInWei);
		}

		LogFundingSuccessful(totalRaised);

		//TODO: Check if funding is completed & pay the beneficiary accordingly

		return contributions.length - 1;

	}

	function getRefund()
	public 
	inState(State.Failed)
	returns (bool)
	{
		for(uint i=0; i<=contributions.length; i++){
			if(contributions[i].contributor == msg.sender){
				uint amountToRefund = contributions[i].amount;
				contributions[i].amount = 0;
				if(!contributions[i].contributor.send(amountToRefund)){
					contributions[i].amount = amountToRefund;
					return false;
				}else {
					totalRaised -= amountToRefund;
					currentBalance = totalRaised;
				}
				return true;
			}
		}

		return false;
	}



 function removeContract()
 public
 isCreator()
 atEndofLifecycle()
 {
 	selfdestruct(msg.sender);
 }

 function () public {
 	revert();
 }

}