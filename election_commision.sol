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
    
    constructor() {

        admin = msg.sender;

    }


    modifier adminOnly() {

        require(msg.sender == admin,"No admin");

        _;

    }

    event consolePrint( string, uint, string);

    event consolePrint(string);

    event Log(string message);

    event LogBytes(bytes data);

    function approveCandidate(address election, uint256 id) public adminOnly {

        require(election != address(0),"Invalid Address");

        Election e = Election(election);

        try e.approveCandidiate(id){

            emit consolePrint("Candidate with the Id: ", id," has been approved");

        }

        catch Error(string memory reason) {

            // catch failing require()
            emit Log(reason);

        }
        catch (bytes memory reason) {

             // catch any exception
            emit LogBytes(abi.encode(reason));

        }

    }


    function setStart(address election, uint256 time) public adminOnly {

        Election e = Election(election);

        try e.setStart(time) {

            emit consolePrint("SetStart Success");

        }

        catch Error(string memory reason){

            emit Log(reason);

        } 
        catch (bytes memory reason) {

             // catch any exception
            emit LogBytes(abi.encode(reason));

        }

    }


    function setStop(address election, uint256 time) public adminOnly {

        Election e = Election(election);

        try e.setStop(time) {

            emit consolePrint("SetStart Success");

        }

        catch Error(string memory reason){

            emit Log(reason);

        } 
        catch (bytes memory reason) {

             // catch any exception
            emit LogBytes(abi.encode(reason));

        }

    }


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
Footer
