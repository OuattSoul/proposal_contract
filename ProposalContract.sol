// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address owner;
    uint256 private counter;

    struct Proposal {
        string description; // Description of the proposal
        string proposal_title; // Proposal's title
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
        
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    address[] private voted_addresses;

    constructor(){
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can do this");
        _;
    }
    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    /*modifier newVoter(address _address) {
        require (!isVoted(_address), "This address already voted");
        _;
    }*/

    function createProposal(string memory _proposal_title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_proposal_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
    }

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function vote(uint8 choice) external {
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        // Second part
        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        // Third part
        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }

        
    }

    function calculateCurrentState () private view returns(bool) {
            Proposal storage proposal = proposal_history[counter];

            uint256 approve = proposal.approve;
            uint256 reject = proposal.reject;
            uint256 pass = proposal.pass;

            if (approve > reject + pass) {
                return true;
            } else {
                return false;
            }
    }
    
   
}
