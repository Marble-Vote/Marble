pragma solidity ^0.4.24;
// We have to specify what version of compiler this code will compile with

 interface MarbleEarth { 

  function addVoter(address voterAddress, address verifierAddress, bytes32 identity) external; 
  function isVoter(address potentialVoter) external returns (bool);
  function getRollSize() external returns (uint);

}

contract EjectionMoon {
  
    struct NewVoter {

      uint timeAdded;
      uint64 votes;
      bytes32 proof;
      mapping (address => bool) supportMap;

  }

  MarbleEarth public marbleEarth = MarbleEarth(0x8D7dDaD45789a64c2AF9b4Ce031C774e277F1Cd4);
  
  mapping (address => NewVoter) public proposedVoters;
  address[] public proposedVotersIndex;

  event VoterProposed(address indexed proposed, bytes32 argument);  
  event VoterSupported(address indexed supported, bool elected);  

  function propose(bytes32 proof) external {
        //has the oldest proposed voter been given a whole week? if so, purge that voter
    if ((block.timestamp - proposedVoters[proposedVotersIndex[0]].timeAdded) > 604800) {

      delete proposedVoters[proposedVotersIndex[0]];
      delete proposedVotersIndex[0];

      }
          //is the proposed voter list full? 
    if (proposedVotersIndex.length >= 1000) {
      return;
      }
        //is this proposed voter already on the proposed voter list? 
    if (proposedVoters[msg.sender].timestamp != 0) {
      return;
    }

    NewVoter memory newVoter;
    newVoter.proof = proof;
    newVoter.timeAdded = block.timestamp;
    proposedVoters[msg.sender] = newVoter;

    emit VoterProposed(msg.sender, proof);
    }

  function supportNewVoter(address supportedAddress) external {
    //is this supporter on the rolls?
    if (!marbleEarth.isVoter(msg.sender)) {
      return;
    }  
    //has this supporter supported for this address already?
    if (proposedVoters[supportedAddress].supportMap[msg.sender] == true) {
      return;
    }

      proposedVoters[supportedAddress].supportMap[msg.sender] = true;
      proposedVoters[supportedAddress].votes++;
    
    if (proposedVoters[supportedAddress].votes*100 / marbleEarth.getRollSize() > 50) {

        marbleEarth.addVoter(supportedAddress, msg.sender, proposedVoters[supportedAddress].proof);
        delete proposedVoters[supportedAddress];

    }

    emit VoterSupported(supportedAddress, elected);
  }

}