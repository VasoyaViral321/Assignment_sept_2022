// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Election2022 {

    struct Candidate{

        bool approved;

        address id;

        uint voteCount;

        string candidateName;

    }
    

    mapping (address=>bool) public voters;

    mapping (uint=> Candidate)public candidates;

    address ecadmin;

    address payable ec;

    uint public candidatesCount;

    uint256 public startTime;

    uint256 public stopTime;


    constructor( address _admin) {

        require(_admin != address(0), "invalid address");

        assert(_admin != 0x0000000000000000000000000000000000000001);

        ecadmin = _admin;

    }


    modifier ecOnly() {
        require(msg.sender == address(ec),"EC only operation");
        _;
    }


    modifier ecAdminOnly() {
        require(msg.sender == ecadmin,"EC admin only operation");
        _;
    }


    function setEC(address _ec) public ecAdminOnly {
        ec = payable(_ec);
    }


    function addCandidate(string memory _name) public payable  {

        require(msg.value == 1 ether,"Appropraite ether not next");

        candidatesCount++;

        candidates[candidatesCount]=Candidate(false,msg.sender,0,_name);

        (bool success, ) = payable(ec).call{value: msg.value}("");

        require(success, "Failed to send Ether");
        
    }   


    function approveCandidiate(uint256 num) external ecOnly {

        require(candidates[num].id != address(0x00), "Not registered" );

        require(candidates[num].approved == false, "Already approved" );

        candidates[num].approved = true;

    }

    event consolePrint(string, uint256);

    function setStart(uint256 num) external ecOnly {

        require(num > block.timestamp,"Start at later time" );

        startTime = num;

        emit consolePrint("Voting starts at: ", startTime);

    }


    function setStop(uint256 num) external ecOnly {

        require(num > block.timestamp && num > startTime,"Stop at later time" );

        stopTime = num;

        emit consolePrint("Voting ends at: ", stopTime);

    }


    event consolePrint(address, string);

    function vote(uint _candidateId) public{

        require(block.timestamp > startTime,"Election not started" );

        require(block.timestamp <= stopTime,"Election over" );

        require(voters[msg.sender] == false, "Already voted");

        require(candidates[_candidateId].id != address(0x00), "Not registered condidate" );

        require(candidates[_candidateId].approved == true, "Dont vote not approved" );

        voters[msg.sender] == true;

        candidates[_candidateId].voteCount++;

        emit consolePrint(msg.sender, " Voted now");

    }

    function getResults() public view returns (Candidate memory candidate) {

        require(block.timestamp >= stopTime,"Election yet to finish" );

        uint256 c;

        uint256 max=0;

        for( uint i =1; i<=candidatesCount; i++) {

            if ( candidates[i].voteCount > max ) {

                max = candidates[i].voteCount;

                c = i;

            }
        }

        return candidates[c];
    }


    function close() public ecOnly{

        selfdestruct(payable(msg.sender));

    }

}
