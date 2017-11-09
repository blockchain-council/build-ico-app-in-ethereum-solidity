pragma solidity ^0.4.16;

contract token {
	function transfer (address receiver, uint amount) public ;
	function mintToken (address target, uint mintedAmount) public ;
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

	function contribute() public pure {
		
	}

}
