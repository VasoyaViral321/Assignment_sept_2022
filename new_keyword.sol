// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface Election {

    function approveCandidiate(uint256 num) external;

    function setStart(uint256 start) external;

    function setStop(uint256 stop) external;

    function getResults() external;

    function close() external;

}


contract ElectionCommision {
    
    address public admin;

    Election2022 election2022;
    
    constructor() {

        admin = msg.sender;

    }


    modifier adminOnly() {

        require(msg.sender == admin,"No admin");

        _;

    }

    event consolePrint( string, uint, string);
    event Log(string message);
    event LogBytes(bytes data);



/*------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------*/

    //Creating new instance of Election2022 with election commission 
    
    // Creating new instanceOf Election2022
    Election2022 el2022 = new Election2022(msg.sender);

    function ADDING_CANDIDATE(string memory _name) public {

        //Adding candidate
        el2022.addCandidate(_name);


    }

    function FETCH_CANDIDATECOUNT() public view returns (uint){

        // fetching Total number of candidates
        return el2022.candidatesCount();

    }



    function approveCandidate(uint256 id) public adminOnly {

        el2022.approveCandidiate(id);

    }


    function setStart(uint256 time) public adminOnly {

         el2022.setStart(time);

    }


    function setStop(uint256 time) public adminOnly {

        el2022.setStop(time);

    }


/*------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------*/

    function withdraw() public {

        uint amount = address(this).balance;

        (bool success, ) = admin.call{value: amount}("");

        require(success, "Failed to send Ether");

    }


    function close() public adminOnly{

        selfdestruct(payable(msg.sender));

    }


    receive() external payable {}

    
    fallback() external payable {}

}

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

        (bool success, ) = ec.call{value: msg.value}("");

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


   



}
