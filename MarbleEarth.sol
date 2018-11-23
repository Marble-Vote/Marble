pragma solidity ^0.4.24;

contract MarbleEarth {

  struct NewMoon {

    uint timeAdded;
    uint8 moonType;
    uint64 yea;
    uint64 nay;
    mapping (address => bool) supportMap;

  }

  MBLToken public tokenContract = MBLToken(0x3DADd4EC1a4Cfc1D035cD6C65262D06294Fe626b);
  LotteryMoon public lotteryContract = LotteryMoon(lotteryAddress);
  uint32 moonElectionPeriod = 604800;

  address[] addresses = [0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd];
  string[] identities = ["https://www.linkedin.com/in/jp-mohler/"];

  mapping (address => string) voterMap;
  uint voterCount = 0;


  mapping (address => NewMoon) public proposedMoons;
  address[] public proposedMoonsIndex;

  address public verificationAddress;
  address public ejectionAddress;
  address public lotteryAddress;

  event NewMoonEvent(address newMoonAddress);

 constructor() public {

    voterMap[0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd] = "https://www.linkedin.com/in/jp-mohler/";
    verificationAddress = 0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd;

  }

//PROPOSE
  function proposeNewMoon(address moonAddress, uint8 moonType) public {
   
      if (!isVoter(msg.sender)) {
      return;
    }

    if (isMoonProposed(moonAddress)) {
      return;
    }
     addNewMoon(moonAddress, moonType);
  }

  function isVoter(address potentialVoter) view public returns (bool) {
    bytes memory memString = bytes(voterMap[potentialVoter]); 
    if (memString.length != 0) {
        return true;
    }
    return false;
  }

  function isMoonProposed(address moonAddress) view public returns (bool) {

    if (proposedMoons[moonAddress].timeAdded > 0) {
      return true; }

    return false;

  }


  function addNewMoon(address moonAddress, uint8 moonType) public {
    
      emit NewMoonEvent(moonAddress);
      proposedMoons[moonAddress] = NewMoon(block.timestamp, moonType, 0, 0);
      proposedMoonsIndex.push(moonAddress);

  }


//SUPPORT

    function voteOnMoon(address newMoonAddress, bool vote) public {

      if (!isValidSupporter(newMoonAddress, msg.sender)) {
        return;
      }

      castVote(newMoonAddress, msg.sender, vote);
    if (vote) {
    if (hasSuperMajority(newMoonAddress)) {
      replaceNewMoon(proposedMoons[newMoonAddress].moonType, newMoonAddress);
    }
}
  }


  function isValidSupporter(address newMoonAddress, address voter) view public returns (bool) {

      if (!isVoter(voter) || alreadyVoted(newMoonAddress, voter)) {
      return false;
    }

    return true;
  }

  function alreadyVoted(address moonAddress, address voterAddress) view public returns (bool) {

    if (proposedMoons[moonAddress].supportMap[voterAddress]) {
      return true;
    }
    return false;
  } 

  function castVote(address moonAddress, address voterAddress, bool supports) public {
      proposedMoons[moonAddress].supportMap[voterAddress] = true;

      if (supports) { 
        proposedMoons[moonAddress].yea++;

      }
      else {
        proposedMoons[moonAddress].nay++;

      }
  }


function winsElection(address moonAddress) view public returns (bool) {

    if (hasSuperMajority(moonAddress) && electionLongEnough(moonAddress)) {
    return true;
    }
    return false;
  }

function hasSuperMajority(address moonAddress) view public returns (bool) {

  if (getYeaNayRatio(moonAddress) >= 67) {
    return true;
  }
return false;
}

function electionLongEnough(address moonAddress) view public returns (bool) {
  uint timeAdded = proposedMoons[moonAddress].timeAdded;

  if (getTimeSince(timeAdded) > moonElectionPeriod) {
      return true;
    }
    return false;
}

 function getTimeSince(uint time) view public returns (uint) {
    return (block.timestamp - time);
  }


function getYeaNayRatio(address moonAddress) view public returns (uint64) {

      uint64 yeas = getYeasByMoon(moonAddress);
      uint64 yeasRatio = (yeas*100)/(getNaysByMoon(moonAddress)+yeas);

      return yeasRatio;
  }


  function getNaysByMoon(address moonAddress) view public returns (uint64) {
    return proposedMoons[moonAddress].nay;
  }


    function getYeasByMoon(address moonAddress) view public returns (uint64) {
    return proposedMoons[moonAddress].yea;
  }

  function replaceNewMoon(uint8 moonType, address newMoonAddress) internal {

      if (moonType == 0) {
       verificationAddress = newMoonAddress;
      }

      else if (moonType == 1) {
        ejectionAddress = newMoonAddress;
      }

      else if (moonType == 2) {
        lotteryAddress = newMoonAddress;
      }

  }

  function getVotersByIndex(uint index) view external returns (address){
    return addresses[index];
  }

  function getBalance() view public returns (uint256) {
        return tokenContract.balanceOf(this);
    }

  function getIdentitiesByIndex(uint index) view external returns (string) {
    return identities[index];
  }

  function getRollSize() view external returns (uint) {
    return addresses.length;
  }

  function getVerificationAddress() view external returns (address) {
    return verificationAddress;
  }

    function getEjectionAddress() view external returns (address) {
    return ejectionAddress;
  }

  function sentByVerificationAddress() view public returns (bool) {
      if (msg.sender == verificationAddress) {
        return true;
      }
      return false;
  }

  function sentByEjectionAddress() view public returns (bool) {
      if (msg.sender == ejectionAddress) {
        return true;
      }
      return false;
  }

  function addVoterAddress(address voterAddress) public {
    addresses.push(voterAddress);
  }

  function addVoterIdentity(string voterIdentity) public {
    identities.push(voterIdentity);
  }

  function addVoterToMap(address voterAddress, string voterIdentity) public {
    voterMap[voterAddress] = voterIdentity;
  }

  function voteCountBump() public {
        voterCount++;
  }


  function addVoter(address voterAddress, address verifierAddress, string identity) external {
  
    if (!sentByVerificationAddress() || isVoter(voterAddress))
      return;
   
    addVoterAddress(voterAddress);
    addVoterIdentity(identity);
    addVoterToMap(voterAddress, identity);
    voteCountBump();
    lotteryContract.enterLottery(voterAddress, verifierAddress);

  }


  function rewardLotteryWinner(address winnerAddress) public returns (bytes32) {

             tokenContract.transfer(winnerAddress, getBalance()/5);
  }

  function ejectVoter(address ejectedAddress, uint arrayIndex) external {
    
    if (!sentByEjectionAddress())
      return;

    if (addresses[arrayIndex] != ejectedAddress)
      return;

      delete addresses[arrayIndex];
      delete identities[arrayIndex];
      delete voterMap[ejectedAddress];

  }

}

contract LotteryMoon {
  function enterLottery(address voterAddress, address verifierAddress) external;
 }

contract MBLToken {
  function transfer(address _to, uint256 _value) public;
  function balanceOf(address _tokenOwner) external view returns (uint balance);
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
 }