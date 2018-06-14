pragma solidity ^0.4.21;
// We have to specify what version of compiler this code will compile with

contract MarbleEarth {

  struct NewMoon {

    uint timeAdded;
    uint8 moonType;
    uint64 votes;
    mapping (address => bool) supportMap;

  }

 // enum MoonType { Verification, Ejection}

  MBLToken tokenContract = MBLToken(0x8D7dDaD45789a64c2AF9b4Ce031C774e277F1Cd4);

  address[] addresses = [0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd];
  string[] identities = ["https://www.linkedin.com/in/jp-mohler/"];
  mapping (address => string) voterMap;

  mapping (address => NewMoon) public proposedMoons;
  address[] public proposedMoonsIndex;

  address public verificationAddress;
  address public ejectionAddress;
  address public lastVerified;

  uint public lastBlockNumber = 0;
  bytes32 public secondLastHash = "";

/*
  event NewVoter(address indexed voter, string proof);
  event EjectedVoter(address indexed voter);
  event NewMoonProposed(address indexed moon);*/

  function MarbleEarth() public {
    voterMap[0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd] = "https://www.linkedin.com/in/jp-mohler/";

  }
  //not being used by any moons currently
  function getVotersByIndex(uint index) view external returns (address){
    return addresses[index];
  }
  //not being used by any moons currently
  function getIdentitiesByIndex(uint index) view external returns (string) {
    return identities[index];
  }

  function getProposedMoonsByIndex(uint index) view external returns (address) {
    return proposedMoonsIndex[index];
  }

  function getProposedMoonsSize() view external returns (uint) {
    return proposedMoonsIndex.length;
  }
  

  function getRollSize() view external returns (uint) {
    return addresses.length;
  }

  function isProposedMoon(address potentialAddress) view external returns (bool) {
    if (proposedMoons[potentialAddress].votes > 0 ) {
      return true;
    }
    return false;
  }

  function getVMAddress() view external returns (address) {
    return verificationAddress;
  }

    function getEjectionAddress() view external returns (address) {
    return ejectionAddress;
  }

  function isVoter(address potentialVoter) view public returns (bool) {
    bytes memory memString = bytes(voterMap[potentialVoter]); // Uses memory
    if (memString.length != 0) {
        return true;
    }
    return false;
  }

  function proposeNewMoon(address moonAddress, uint8 moonType) public {
   
      if (!isVoter(msg.sender)) {
      return;
    }

    if (proposedMoons[moonAddress].supportMap[msg.sender]) {
      return;
    }

    if ((block.timestamp - proposedMoons[proposedMoonsIndex[0]].timeAdded) > 172800) {

      delete proposedMoons[proposedMoonsIndex[0]];
      delete proposedMoonsIndex[0];

      }

    if (proposedMoonsIndex.length >= 1000) {
      return;
      }

      proposedMoons[moonAddress] = NewMoon(block.timestamp, moonType, 1);
      proposedMoonsIndex.push(moonAddress);
     // emit NewMoonProposed(moonAddress);

  }

  function supportNewMoon(address newMoonAddress) public {

    if (!isVoter(msg.sender)) {
      return;
    }

    if (proposedMoons[newMoonAddress].supportMap[msg.sender]) {
      return;
    }

      proposedMoons[newMoonAddress].supportMap[msg.sender] = true;
      proposedMoons[newMoonAddress].votes++;

    if ((proposedMoons[newMoonAddress].votes*100)/addresses.length >= 50) {
      replaceNewMoon(proposedMoons[newMoonAddress].moonType, newMoonAddress);
    }

  }

  function replaceNewMoon(uint8 moonType, address newMoonAddress) internal {

      if (moonType == 0) {
       verificationAddress = newMoonAddress;
      }

      else if (moonType == 1) {
        ejectionAddress = newMoonAddress;
      }

      delete proposedMoons[newMoonAddress]; 

  }

  function _addVoter(address voterAddress, address verifierAddress, string identity) internal {

    addresses.push(voterAddress);
    identities.push(identity);
    voterMap[voterAddress] = identity;

    tokenContract.transfer(voterAddress, newVoterAllocation());
    tokenContract.transfer(verifierAddress, verifierAllocation());

    lastVerified = voterAddress;
    lastBlockNumber = block.number;

   // emit NewVoter(voterAddress, identity);

  }

  function addVoter(address voterAddress, address verifierAddress, string identity) external {
    //coming from verification moon?
    if (msg.sender != verificationAddress)
      return;
     // already on Rolls?
    if (isVoter(voterAddress)) {
      return;
    }

      _addVoter(voterAddress, verifierAddress, identity);

  }

  function getBalance() view public returns (uint256) {
        return tokenContract.balanceOf(this);
    }

    function verifierAllocation() view internal returns (uint) {
      uint contractBalance = getBalance();
      return contractBalance/500000;

    }

  function newVoterAllocation() internal returns (uint) {
      uint contractBalance = getBalance();
      if (addresses.length < 1000000) {runLottery(contractBalance); }
      return contractBalance*4/500000;

  }

  function runLottery(uint contractBalance) internal {

            bytes32 lastBlockHash = block.blockhash(lastBlockNumber);
            bytes32 lastHash = keccak256(lastVerified, lastBlockHash); 
            uint lotteryNumber = _getHashOfHashes(secondLastHash, lastHash); 
     
         //1 in 1000 chance
        if (addresses.length < 1000 && lotteryNumber < 2**246) {
             tokenContract.transfer(lastVerified, contractBalance/5);
        } 
        //1 in 1 million chance
        else if (lotteryNumber < 2**236)  {
             tokenContract.transfer(lastVerified, contractBalance/5);
       }

       secondLastHash = lastHash;
  }

  function _getHashOfHashes(bytes32 _secondLastHash, bytes32 lastHash) pure internal returns (uint) {
            bytes32 hashOfHashes = keccak256(_secondLastHash, lastHash); 
            uint lotteryNumber = uint(hashOfHashes);
            return lotteryNumber;
  }

  function getHashOfHashes(bytes32 _secondLastHash, bytes32 lastHash) pure external returns (uint) {
    return _getHashOfHashes(_secondLastHash, lastHash);
  }

  function ejectVoter(address ejectedAddress, uint arrayIndex) external {
    
    if (msg.sender != ejectionAddress)
      return;

    if (addresses[arrayIndex] != ejectedAddress)
      return;

      delete addresses[arrayIndex];
      delete identities[arrayIndex];
      delete voterMap[ejectedAddress];
   //   emit EjectedVoter(ejectedAddress);

  }

}

contract MBLToken {
    function transfer(address _to, uint256 _value) public;
    function balanceOf(address _tokenOwner) external view returns (uint balance);

 }


