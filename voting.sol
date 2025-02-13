// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVoting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedCandidateId;
    }

    address public admin;
    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;
    uint public votersCount;
    bool public votingOpen;

    event CandidateAdded(uint id, string name);
    event VoterRegistered(address voter);
    event VoteCasted(address voter, uint candidateId);
    event VotingStarted();
    event VotingEnded();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyDuringVoting() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        admin = msg.sender;
        votingOpen = false;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");
        voters[_voter] = Voter(true, false, 0);
        votersCount++;
        emit VoterRegistered(_voter);
    }

    function startVoting() public onlyAdmin {
        require(!votingOpen, "Voting already started");
        votingOpen = true;
        emit VotingStarted();
    }

    function endVoting() public onlyAdmin {
        require(votingOpen, "Voting is not open");
        votingOpen = false;
        emit VotingEnded();
    }

    function vote(uint _candidateId) public onlyDuringVoting {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    function getResults() public view returns (uint winnerId, string memory winnerName, uint winnerVoteCount) {
        uint highestVoteCount = 0;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > highestVoteCount) {
                highestVoteCount = candidates[i].voteCount;
                winnerId = candidates[i].id;
                winnerName = candidates[i].name;
                winnerVoteCount = candidates[i].voteCount;
            }
        }
    }
}
