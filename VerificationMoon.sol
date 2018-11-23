pragma solidity ^0.4.21;
// We have to specify what version of compiler this code will compile with

 interface MarbleEarth { 

  function addVoter(address voterAddress, address verifierAddress, string identity) external; 
  function isVoter(address potentialVoter) external returns (bool);
  function getRollSize() external returns (uint);

}

contract VerificationMoon {
  
   event NewProposed(address newProposedAddress);

    struct NewVoter {

      uint timeAdded;
      uint64 yea;
      uint64 nay;
      string proof;
      mapping (address => bool) supportMap;

  }

  MarbleEarth public marbleEarth = MarbleEarth(0xBEb9BA7Af24ef5169b5a23BF22FD46776b92F2B5);
  mapping (address => NewVoter) public proposedVoters;
  uint32 electionPeriod = 604800;



  function propose(string proof) external {

    if (alreadyProposed(msg.sender)) {
      return;
    }

    emit NewProposed(msg.sender);
    addNewProposed(msg.sender, proof);

    }

  function alreadyProposed(address supportedAddress) view public returns (bool) {
  
   if (proposedVoters[supportedAddress].timeAdded > 0) {
      return true;
    }
    return false;
   }

  function addNewProposed(address newProposed, string proof) public {
      
      proposedVoters[newProposed] = NewVoter(block.timestamp, 0, 0, proof);

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
        addVoter(supportedAddress, msg.sender, proposedVoters[supportedAddress].proof);
    }

  }

   function isVoter(address voterAddress) public returns (bool) {
    if (marbleEarth.isVoter(voterAddress)) {
      return true;
    }  
    return false;
   }

   function isSupporter(address supporter, address voter) view public returns (bool) {

      if (proposedVoters[voter].supportMap[supporter] == true) {
      return true; }
      return false;

   }

  function vote(address supportedAddress) public {

      proposedVoters[supportedAddress].supportMap[msg.sender] = true;
      proposedVoters[supportedAddress].yea++;

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
  uint timeAdded = proposedVoters[voterAddress].timeAdded;

  if (getTimeSince(timeAdded) > electionPeriod) {
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
    return proposedVoters[voterAddress].nay;
  }


    function getYeasByVoter(address voterAddress) view public returns (uint64) {
    return proposedVoters[voterAddress].yea;
  }


   function addVoter(address newVoter, address verifier, string proof) public {
      marbleEarth.addVoter(newVoter, verifier, proof);
   }

  function getProofByAddress(address proposedAddress) view external returns (string) {
    return proposedVoters[proposedAddress].proof;
  }  

}