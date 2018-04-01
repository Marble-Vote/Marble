pragma solidity ^0.4.18;


interface MarbleEarth { function ejectVoter(address ejectedAddress, uint arrayIndex) external; }


contract EjectionMoon {
  
    struct NewEjection {

      uint timeAdded;
      uint64 votes;
      bytes32 argument;
      mapping (address => bool) supportMap;

  }

  address public marbleEarthAddress;
  mapping (address => NewEjection) public proposedEjections;
  uint16 public numberOfProposed;
  address[] public voterAddresses;
  bytes32[] public voterIdentities;

  function propose(address proposed, bytes32 argument, address[] addresses, bytes32[] identities) external {

    if (msg.sender != marbleEarthAddress)
      return;

    voterAddresses = addresses;
    voterIdentities = identities;

    NewEjection memory newEjection;
    newEjection.argument = argument;
    newEjection.timeAdded = block.timestamp;
    proposedEjections[proposed] = newEjection;

  }

  function ejectVoter(address ejectedAddress, uint arrayIndex) internal {

         MarbleEarth marbleEarth = MarbleEarth(marbleEarthAddress);
         marbleEarth.ejectVoter(ejectedAddress, arrayIndex);

  }

  function supportNewEjection(address _address, uint arrayIndex) public {

    if ((block.timestamp - proposedEjections[0].timeAdded) > 604800) {

      delete proposedEjections[0];
      numberOfProposed--;

      }

    if (numberOfProposed >= 1000) {

      return;

      }

    if (!proposedEjections[_address].supportMap[msg.sender]) {
      proposedEjections[_address].supportMap[msg.sender] = true;
      proposedEjections[_address].votes++;
      numberOfProposed++;

    }

    if (proposedEjections[_address].votes*100 / voterAddresses.length > 50) {

        ejectVoter(_address, arrayIndex);
        delete proposedEjections[_address];
        numberOfProposed--;

    }
  }
}
