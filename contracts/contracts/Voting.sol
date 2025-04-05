// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Voting is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Election {
        uint256 id;
        string title;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        mapping(uint256 => Candidate) candidates;
        uint256 candidateCount;
        mapping(address => bool) hasVoted;
    }

    IERC20 public votingToken;
    mapping(uint256 => Election) public elections;
    uint256 public electionCount;

    event ElectionCreated(uint256 indexed electionId, string title);
    event VoteCast(address indexed voter, uint256 indexed electionId, uint256 candidateId);
    event ElectionEnded(uint256 indexed electionId);

    constructor(address _votingToken) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        votingToken = IERC20(_votingToken);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    modifier onlyVoter() {
        require(hasRole(VOTER_ROLE, msg.sender), "Caller is not a voter");
        _;
    }

    function createElection(
        string memory _title,
        uint256 _startTime,
        uint256 _endTime,
        string[] memory _candidateNames
    ) external onlyAdmin {
        require(_startTime < _endTime, "Invalid time range");
        require(_candidateNames.length > 0, "No candidates provided");

        uint256 electionId = electionCount++;
        Election storage election = elections[electionId];
        election.id = electionId;
        election.title = _title;
        election.startTime = _startTime;
        election.endTime = _endTime;
        election.isActive = true;

        for (uint256 i = 0; i < _candidateNames.length; i++) {
            election.candidates[i] = Candidate({
                id: i,
                name: _candidateNames[i],
                voteCount: 0
            });
            election.candidateCount++;
        }

        emit ElectionCreated(electionId, _title);
    }

    function castVote(uint256 _electionId, uint256 _candidateId) external nonReentrant onlyVoter {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election is not active");
        require(block.timestamp >= election.startTime, "Election has not started");
        require(block.timestamp <= election.endTime, "Election has ended");
        require(!election.hasVoted[msg.sender], "Already voted");
        require(_candidateId < election.candidateCount, "Invalid candidate");

        election.hasVoted[msg.sender] = true;
        election.candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _electionId, _candidateId);
    }

    function endElection(uint256 _electionId) external onlyAdmin {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election is not active");
        require(block.timestamp > election.endTime, "Election has not ended");

        election.isActive = false;
        emit ElectionEnded(_electionId);
    }

    function getElectionResults(uint256 _electionId) external view returns (
        string memory title,
        uint256[] memory candidateIds,
        string[] memory candidateNames,
        uint256[] memory voteCounts
    ) {
        Election storage election = elections[_electionId];
        uint256 count = election.candidateCount;

        candidateIds = new uint256[](count);
        candidateNames = new string[](count);
        voteCounts = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            Candidate storage candidate = election.candidates[i];
            candidateIds[i] = candidate.id;
            candidateNames[i] = candidate.name;
            voteCounts[i] = candidate.voteCount;
        }

        return (election.title, candidateIds, candidateNames, voteCounts);
    }

    function registerVoter(address _voter) external onlyAdmin {
        _grantRole(VOTER_ROLE, _voter);
    }
} 