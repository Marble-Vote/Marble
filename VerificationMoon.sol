pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with


interface MarbleEarth { function addVoter(address voterAddress, address verifierAddress, bytes32 identity) external; }


contract VerificationMoon {
  
    struct NewVoter {

      uint timeAdded;
      uint64 votes;
      bytes32 argument;
      mapping (address => bool) supportMap;

  }

  address public marbleEarthAddress;
  mapping (address => NewVoter) public proposedVoters;
  uint16 public numberOfProposed;
  address[] public voterAddresses;
  bytes32[] public voterIdentities;
  event VoterProposed(address indexed proposed, bytes32 argument);

  function propose(address selfProposed, bytes32 argument, address[] addresses, bytes32[] identities) external {

    if (msg.sender != marbleEarthAddress)
      return;

    voterAddresses = addresses;
    voterIdentities = identities;

    if (addresses.length == 0) {
        addVoter(selfProposed, selfProposed, argument);
    }
    else {

    NewVoter memory newVoter;
    newVoter.argument = argument;
    newVoter.timeAdded = block.timestamp;
    proposedVoters[selfProposed] = newVoter;

    emit VoterProposed(selfProposed, argument);

    }

  }

  function addVoter(address verifiedAddress,address verifierAddress, bytes32 argument) internal {

         MarbleEarth marbleEarth = MarbleEarth(marbleEarthAddress);
         marbleEarth.addVoter(verifiedAddress, verifierAddress, argument);

  }

  function supportNewVoter(address _address) public {

    if ((block.timestamp - proposedVoters[0].timeAdded) > 604800) {

      delete proposedVoters[0];
      numberOfProposed--;

      }

    if (numberOfProposed >= 1000) {

      return;

      }

    if (!proposedVoters[_address].supportMap[msg.sender]) {
      proposedVoters[_address].supportMap[msg.sender] = true;
      proposedVoters[_address].votes++;
      numberOfProposed++;

    }

    if (proposedVoters[_address].votes*100 / voterAddresses.length > 50) {

        addVoter(_address, msg.sender, proposedVoters[_address].argument);
        delete proposedVoters[_address];
        numberOfProposed--;

    }
  }
}
