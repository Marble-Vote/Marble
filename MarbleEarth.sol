pragma solidity ^0.4.21;
// We have to specify what version of compiler this code will compile with

contract MarbleEarth {

  struct NewMoon {

    uint timeAdded;
    bool verification;
    uint64 yea;
    uint64 nay;
    mapping (address => bool) supportMap;

  }

  MBLToken public tokenContract = MBLToken(0x3DADd4EC1a4Cfc1D035cD6C65262D06294Fe626b);

  address[] addresses = [0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd];
  string[] identities = ["https://www.linkedin.com/in/jp-mohler/"];
  mapping (address => string) voterMap;
  uint voterCount = 0;

  mapping (address => NewMoon) public proposedMoons;
  address[] public proposedMoonsIndex;

  address public verificationAddress;
  address public ejectionAddress;
  address public lastVerified;
  address public lastVerifier;

  uint public lastBlockNumber = 0;
  bytes32 public secondLastHash = "";
  uint8 lotteryCoefficient = 0;

  function MarbleEarth() public {
    voterMap[0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd] = "https://www.linkedin.com/in/jp-mohler/";
    verificationAddress = 0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd;
  }

  function getVotersByIndex(uint index) view external returns (address){
    return addresses[index];
  }

  function transferMBL(address to, uint256 value) public {
    tokenContract.transfer(to, value);
  }

  function transferAuto() public {
    tokenContract.transfer(0xAe4Ef52D81Ed41f8D84bc6512aa52D050c488ddd, 55);
  }

  function getBalance() view public returns (uint256) {
        return tokenContract.balanceOf(this);
    }

  function getIdentitiesByIndex(uint index) view external returns (string) {
    return identities[index];
  }

  function getProposedMoonsByIndex(uint index) view external returns (address) {
    return proposedMoonsIndex[index];
  }

  function getProposedMoonsSize() view external returns (uint) {
    return proposedMoonsIndex.length;
  }

  function getProposedMoonForCount(address moonAddress) view external returns (uint64) {

    return proposedMoons[moonAddress].yea;
  }

  function getProposedMoonAgainstCount(address moonAddress) view external returns (uint64) {

    return proposedMoons[moonAddress].against;
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

  function isVoter(address potentialVoter) view public returns (bool) {
    bytes memory memString = bytes(voterMap[potentialVoter]); 
    if (memString.length != 0) {
        return true;
    }
    return false;
  }

  function doesMoonExist(address moonAddress) view public returns (bool) {

    if (proposedMoons[moonAddress].timeAdded > 0) {
      return true; }

    return false;

  }

  function isNewestMoonStale() view public returns (bool) {
 
   uint newestMoonTimeStamp = proposedMoons[proposedMoonsIndex[4]].timeAdded;
   if ((block.timestamp - newestMoonTimeStamp) > 600) {
      return true;
    }

    return false;
  }

  function isMoonIndexFull() view public returns (bool) {
    if (proposedMoonsIndex.length > 4) {
      return true;
    }
    return false;
  }

  function clearMoons() public {

      for (uint i=0; i<proposedMoonsIndex.length; i++) {
      delete proposedMoons[proposedMoonsIndex[i]];      
       }
       delete proposedMoonsIndex;
  }

  function addNewMoon(address moonAddress, bool verification) public {

      proposedMoons[moonAddress] = NewMoon(block.timestamp, verification, 0);
      proposedMoonsIndex.push(moonAddress);

  }

  function sentByVerificationAddress() view public returns (bool) {
      if (msg.sender == verificationAddress) {
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

  function updateLastVerified(address voterAddress) public {
        lastVerified = voterAddress;
  }
  function updateLastVerifier(address verifier) public {
    lastVerifier = verifier;
  }
  function getLastVerified() view public returns (address) {
    return lastVerified;
  }
  function updateBlockNumber() public {
      lastBlockNumber = block.number;
  }

  function setSecondLastHash(bytes32 lastHash) public {
    secondLastHash = lastHash;
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

  function getYeasByMoon(address moonAddress) public returns (uint64) {
    return proposedMoons[moonAddress].yea;
  }

  function getNaysByMoon(address moonAddress) public returns (uint64) {
    return proposedMoons[moonAddress].nay;
  }
  function getYeaNayRatio(address moonAddress) public returns (uint) {
      return getYeasByMoon(moonAddress)*100/getNaysByMoon(moonAddress);
  }

  function hasSuperMajority(address moonAddress) view public returns (bool) {

    if (getYeaNayRatio(moonAddress) >= 67) {
    return true;
    }
    return false;
  }

  function voteCountBump() public {
        voterCount++;
  }


  function proposeNewMoon(address moonAddress, bool verification) public {
   
      if (!isVoter(msg.sender)) {
      return;
    }

    if (doesMoonExist(moonAddress)) {
      return;
    }

    if (isMoonIndexFull()) {
    if (isNewestMoonStale()) {
        clearMoons();
      }
    else {
       return;
      } 
    }

     addNewMoon(moonAddress, verification);
  }

  function opposeNewMoon (address newMoonAddress) public {

          if (!isValidVoter(newMoonAddress, msg.sender)) {
            return;
          }
          castVote(newMoonAddress, msg.sender, false);

  }

  function isValidVoter(address newMoonAddress, address voter) public returns (bool) {

      if (!isVoter(voter) || alreadyVoted(newMoonAddress, voter)) {
      return false;
    }

    return true;
  }

  function supportNewMoon(address newMoonAddress) public {

      if (!isValidVoter(newMoonAddress, msg.sender)) {
        return;
      }

      castVote(newMoonAddress, msg.sender, true);

    if (hasSuperMajority(newMoonAddress)) {
      replaceNewMoon(proposedMoons[newMoonAddress].verification, newMoonAddress);
    }

  }

  function replaceNewMoon(bool verification, address newMoonAddress) internal {

      if (verification) {
       verificationAddress = newMoonAddress;
      }

      else {
        ejectionAddress = newMoonAddress;
      }

      delete proposedMoons[newMoonAddress]; 

  }

  function addVoter(address voterAddress, address verifierAddress, string identity) external {
  
    if (!sentByVerificationAddress())
      return;
    if (isVoter(voterAddress)) {
      return;
    }
   
    addVoterAddress(voterAddress);
    addVoterIdentity(identity);
    addVoterToMap(voterAddress, identity);
    voteCountBump();

    enterLottery(voterAddress);
    enterLottery(verifierAddress);

    updateLastVerified(voterAddress);
    updateLastVerifier(verifierAddress);

    updateBlockNumber();

  }

  function getLastVoterBlockHash() view public returns (bytes32) {
    return block.blockhash(lastBlockNumber);
  }

  function getHashOfLastVoterAndBlockHash(bytes32 lastBlockHash) view public returns (bytes32) {
    return keccak256(lastVerified, lastBlockHash);
  }

  function fewerVotersThan(uint threshold) view public returns (bool) {
    if (voterCount < threshold) {
      return true;
    }
    return false;
  }

  function isNumberSmaller(uint number, uint threshold)pure public returns (bool) {
    if (number < threshold) {
      return true;
    }
    return false;
  }

    function getHashOfHashes(bytes32 lastHash) view public returns (bytes32) {

            return keccak256(secondLastHash, lastHash); 
  }

  function bytesToInt(bytes32 hashOfHashes) pure public returns (uint) {
            return uint(hashOfHashes);
  }

  function getLotteryCoefficient() view public returns (uint8) {
    return lotteryCoefficient;
  }

  function winsLottery(bytes32 lastHash) view public returns (bool) {

   if (isNumberSmaller(bytesToInt(getHashOfHashes(lastHash)), 2**(245 - lotteryCoefficient))) {
    return true;
           }
    return false;

  }

  function runLottery() public {

    bytes32 lastHash =  getHashOfLastVoterAndBlockHash(getLastVoterBlockHash());
         //1 in 1000 chance
        if (winsLottery(245 - lotteryCoefficient, lastHash)) {
             tokenContract.transfer(lastVerified, getBalance()/5);
             lotteryCoefficient = lotteryCoefficient + 2;
        } 

      setSecondLastHash(lastHash);
  }

  function ejectVoter(address ejectedAddress, uint arrayIndex) external {
    
    if (msg.sender != ejectionAddress)
      return;

    if (addresses[arrayIndex] != ejectedAddress)
      return;

      delete addresses[arrayIndex];
      delete identities[arrayIndex];
      delete voterMap[ejectedAddress];

  }

}

contract MBLToken {
  function transfer(address _to, uint256 _value) public;
  function balanceOf(address _tokenOwner) external view returns (uint balance);
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


 }


