pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with

contract VerificationMoon {
  
    struct NewVoter {

      address voterAddress;
      bytes32 argument;
      uint timeAdded;
      uint votes;
      supporters mapping (address => bool);

  }

  address public marbleEarthAddress;
  NewVoter[] public proposedVoters;


  function propose(address sender, bytes32 argument, address[] addresses, bytes32[] identities) public {

    if (msg.sender != marbleEarthAddress)
      return;

    if (rolls.length == 0) {
        MarbleEarth marbleEarth = MarbleEarth(marbleEarthAddress);
        marbleEarth.addVoter(address, argument);
    }
    else {
    NewVoter newVoter;
    newVoter.voterAddress = sender;
    newVoter.argument = argument;
    proposedVoters.push(newVoter);

    }

  }

  function supportNewVoter(uint16 index, address address) public {

    if ((block.timestamp - proposedVoters[0].timeAdded)) > 604800) {

      delete proposedVoters[0];

      }

    if (proposedVoters.length >= 1000) {

      return;

      }

    NewVoter newVoter = proposedVoters[index];

    if (newVoter.voterAddress == address && !newVoter.supporters[msg.sender]) {
      newVoter.supporters[msg.sender] = true;
      newVoter.votes++;
    }

    if (newVoter.votes / rolls.length > .85) {

        MarbleEarth marbleEarth = MarbleEarth(marbleEarthAddress)
        marbleEarth.addVoter(address, newVoter.argument);

         delete proposedVoters[index];

    }

  }

}