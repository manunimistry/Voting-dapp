// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract Voting {
    enum VoteStates {Absent, Yes, No}

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        mapping (address => VoteStates) voteStates;
    }

    Proposal[] public proposals;

    event ProposalCreated(uint);
    event VoteCast(uint, address indexed);

    mapping (address=>bool) members;

    constructor(address[] memory _members) {
        for (uint i =0; i<_members.length;i++){
           
            members[_members[i]] = true;  
            }
            members[msg.sender] = true;
        
    }
    

    function newProposal(address _target, bytes calldata _data) external {
        emit ProposalCreated(proposals.length);
        require(members[msg.sender]);
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;
    }

    function castVote(uint _proposalId, bool _supports) external {
        Proposal storage proposal = proposals[_proposalId];
        require(members[msg.sender]);
        // clear out previous vote 
        if(proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if(proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

        // add new vote 
        if(_supports) {
            proposal.yesCount++;
        }
        else {
            proposal.noCount++;
        }
        if(proposal.yesCount == 10){
            (bool success, ) = proposal.target.call(proposal.data);
            require(success);
        }
        emit VoteCast(_proposalId, msg.sender);
 
        // we're tracking whether or not someone has already voted 
        // and we're keeping track as well of what they voted
        proposal.voteStates[msg.sender] = _supports ? VoteStates.Yes : VoteStates.No;
    }
}
