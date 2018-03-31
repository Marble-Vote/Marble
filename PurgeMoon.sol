pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with

contract PurgeMoon {
  
    struct NewPurge {

      address voterAddress;
      bytes32 argument;
      uint timeAdded;
      uint votes;
      mapping(address => bool) supporters;

  }

  mapping (address => bytes32) public rolls; 
  address public marbleEarthAddress;
  NewPurge[] public proposedPurge;

  
  function propose(address sender, bytes32 argument, mapping (address => bytes32) rolls) public {

    NewPurge newPurge;
    newPurge.voterAddress = sender;
    newPurge.argument = argument;
    proposedVoters.push(newPurge);

    }

  }

  function supportNewPurge(uint16 index, address address) public {

    if ((block.timestamp - proposedPurge[0].timeAdded)) > 604800) {

      delete proposedPurge[0];

      }

    if (proposedPurge.length >= 1000) {

      return;

      }

    NewPurge newPurge = proposedPurge[index];

    if (newPurge.voterAddress == address && !newPurge.supporters[msg.sender]) {
      newPurge.supporters[msg.sender] = true;
      newPurge.votes++;
    }

    if (newPurge.votes / rolls.length > .85) {
        MarbleEarth marbleEarth = MarbleEarth(marbleEarthAddress);
        marbleEarth.purgeVoter(address);

      delete proposedPurge[index];

    }

  }

}