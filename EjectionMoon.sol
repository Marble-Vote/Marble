pragma solidity ^0.4.21;
// We have to specify what version of compiler this code will compile with

 interface MarbleEarth { 

  function ejectVoter(address ejectedAddress, uint arrayIndex) external;
  function isVoter(address potentialVoter) external returns (bool);
  function getRollSize() external returns (uint);

}

contract EjectionMoon {
  
   event NewProposed(address newProposedAddress);

    struct NewEjection {

      uint timeAdded;
      uint64 yea;
      uint64 nay;
      uint arrayIndex;
      mapping (address => bool) supportMap;

  }

  MarbleEarth public marbleEarth = MarbleEarth(0xBEb9BA7Af24ef5169b5a23BF22FD46776b92F2B5);
  mapping (address => NewEjection) public proposedEjections;
  uint32 selectionPeriod = 604800;



  function propose(address proposedEjection, uint arrayIndex) external {

    if (alreadyProposed(proposedEjection)) {
      return;
    }
    emit NewProposed(msg.sender);
    addNewProposed(proposedEjection, arrayIndex);

    }

  function alreadyProposed(address supportedAddress) view public returns (bool) {
  
   if (proposedEjections[supportedAddress].timeAdded > 0) {
      return true;
    }
    return false;
   }

  function addNewProposed(address newProposed, uint arrayIndex) public {
      
      proposedEjections[newProposed] = NewEjection(block.timestamp, 0, 0, arrayIndex);

   }


  function supportNewVoter(address supportedAddress) external {
    if (!isVoter(msg.sender)) {
      return;
    }  
    if (isSupporter(msg.sender, supportedAddress)) {
      return;
    }

    if (!alreadyProposed(supportedAddress)) {
      return;
    }

    vote(supportedAddress);
    
    if (wins(supportedAddress)) {
        ejectVoter(supportedAddress, proposedEjections[supportedAddress].arrayIndex);
    }

  }

   function isVoter(address voterAddress) public returns (bool) {
    if (marbleEarth.isVoter(voterAddress)) {
      return true;
    }  
    return false;
   }

   function isSupporter(address supporter, address voter) view public returns (bool) {

      if (proposedEjections[voter].supportMap[supporter] == true) {
      return true; }
      return false;

   }

  function vote(address supportedAddress) public {

      proposedEjections[supportedAddress].supportMap[msg.sender] = true;
      proposedEjections[supportedAddress].yea++;

   }

function wins(address supportedAddress) view public returns (bool) {

    if (hasSuperMajority(supportedAddress) && electionLongEnough(supportedAddress)) {
    return true;
    }
    return false;
  }

function hasSuperMajority(address voterAddress) view public returns (bool) {

  if (getYeaNayRatio(voterAddress) >= 50) {
    return true;
  }
return false;
}

function electionLongEnough(address voterAddress) view public returns (bool) {
  uint timeAdded = proposedEjections[voterAddress].timeAdded;

  if (getTimeSince(timeAdded) > selectionPeriod) {
      return true;
    }
    return false;
}

 function getTimeSince(uint time) view public returns (uint) {
    return (block.timestamp - time);
  }

function getYeaNayRatio(address voterAddress) view public returns (uint) {

      uint yeas = getYeasByVoter(voterAddress);
      return (yeas*100)/(getNaysByVoter(voterAddress)+yeas);
  }


  function getNaysByVoter(address voterAddress) view public returns (uint64) {
    return proposedEjections[voterAddress].nay;
  }


    function getYeasByVoter(address voterAddress) view public returns (uint64) {
    return proposedEjections[voterAddress].yea;
  }


   function ejectVoter(address supportedAddress, uint arrayIndex) public {
      marbleEarth.ejectVoter(supportedAddress, arrayIndex);
   }

  function getProofByAddress(address proposedAddress) view external returns (uint) {
    return proposedEjections[proposedAddress].arrayIndex;
  }  

}