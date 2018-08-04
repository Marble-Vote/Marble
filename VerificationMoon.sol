pragma solidity ^0.4.21;
// We have to specify what version of compiler this code will compile with

 interface MarbleEarth { 

  function addVoter(address voterAddress, address verifierAddress, string identity) external; 
  function isVoter(address potentialVoter) external returns (bool);
  function getRollSize() external returns (uint);

}

contract VerificationMoon {
  
    struct NewVoter {

      uint timeAdded;
      uint64 votes;
      string proof;
      mapping (address => bool) supportMap;

  }

  MarbleEarth public marbleEarth = MarbleEarth(0xBEb9BA7Af24ef5169b5a23BF22FD46776b92F2B5);
  mapping (address => NewVoter) public proposedVoters;
  address[] public proposedVotersIndex;

//external getters for checking state of moon
  function getVotesByAddress(address proposedAddress) view external returns (uint) {
    return proposedVoters[proposedAddress].votes;
  }

  function getProofByAddress(address proposedAddress) view external returns (string) {
    return proposedVoters[proposedAddress].proof;
  }  
  function getIndexSize() view external returns (uint) {
      return proposedVotersIndex.length;
   }

   function getAddressByIndex(uint16 index) view external returns (address) {

    if (proposedVotersIndex.length > index) {
    return proposedVotersIndex[index];
 }
  return 0;

   }

   function isVoter(address voterAddress) public returns (bool) {
    if (marbleEarth.isVoter(voterAddress)) {
      return true;
    }  
    return false;
   }

   function isIndexFull() view public returns (bool) {
    if (proposedVotersIndex.length > 99) {
      return true;
    }
    return false;
   }

   function isNewestVoterStale() view public returns (bool) {
   
    if ((block.timestamp - proposedVoters[proposedVotersIndex[99]].timeAdded) > 600) { 
      return true;
    }
    return false;

   }

   function clearVoterList() public returns (bool) {

     for (uint i=0; i<proposedVotersIndex.length; i++) {
      delete proposedVoters[proposedVotersIndex[i]];      
       }
      delete proposedVotersIndex;

   }

   function doesVoterExist(address supportedAddress) view public returns (bool) {
   if (proposedVoters[supportedAddress].timeAdded > 0) {
      return true;
    }
    return false;
   }

   function isSupporter(address supporter, address voter) view public returns (bool) {

      if (proposedVoters[voter].supportMap[supporter] == true) {
      return true; }
      return false;

   }

   function addVoter(address newVoter, address verifier, string proof) public {
      marbleEarth.addVoter(newVoter, verifier, proof);
   }

   function vote(address supportedAddress) public {

      proposedVoters[supportedAddress].supportMap[msg.sender] = true;
      proposedVoters[supportedAddress].votes++;

   }

   function hasMajority(address supportedAddress) public returns (bool) {
    if ((proposedVoters[supportedAddress].votes*100 / marbleEarth.getRollSize()) > 50) {
      return true;
    }
    return false;
   }

   function addNewProposed(address newProposed, string proof) public {
    NewVoter memory newVoter;
    newVoter.proof = proof;
    newVoter.timeAdded = block.timestamp;
    proposedVoters[newProposed] = newVoter;
    proposedVotersIndex.push(newProposed);
   }

   function deleteVoter(address voterAddress) public {
        delete proposedVoters[voterAddress];
   }

  function propose(string proof) external {
    //has the oldest proposed voter been given a whole week? if so, purge that voter, should be 604800
    if (doesVoterExist()) {
      return;
    }

    if (isIndexFull()) {
      if (isNewestVoterStale()) {
          clearVoterList();
      }
      else {
        return;
      }
    }   
        //is this proposed voter already on the proposed voter list? 
    addNewProposed(msg.sender, proof);

    }

  function supportNewVoter(address supportedAddress) external {
    //is this supporter on the rolls?
    if (!isVoter(msg.sender)) {
      return;
    }  
    //has this supporter supported for this address already?
    if (isSupporter(msg.sender, supportedAddress)) {
      return;
    }

    if (!doesVoterExist(supportedAddress)) {
      return;
    }

    vote(supportedAddress);
    
    if (hasMajority(supportedAddress)) {
        addVoter(supportedAddress, msg.sender, proposedVoters[supportedAddress].proof);
        deleteVoter(supportedAddress);
    }

  }

}