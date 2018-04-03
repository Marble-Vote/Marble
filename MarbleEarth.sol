pragma solidity ^0.4.21;
// We have to specify what version of compiler this code will compile with


contract MarbleEarth {


  struct NewMoon {

    uint timeAdded;
    MoonType moonType;
    uint64 votes;
    mapping (address => bool) supportMap;

  }


  enum MoonType { Verification, Ejection}

  MBLToken tokenContract;
  VerificationMoon verificationContract;
  EjectionMoon ejectionContract;

  address[] addresses;
  bytes32[] identities;
  mapping (address => bytes32) voterMap;

  mapping (address => NewMoon) public proposedMoons;
  address[] public proposedMoonsIndex;

  address public verificationAddress;
  address public ejectionAddress;
  address public tokenAddress = 0x8D7dDaD45789a64c2AF9b4Ce031C774e277F1Cd4;

  address public lastVerified;

  event NewVoter(address indexed voter, bytes32 proof);
  event EjectedVoter(address indexed voter);
  event NewMoonProposed(address indexed moon);

  function MarbleEarth() public {

    verificationAddress = 0x7413FCf03b08bB07e5992608A000857833e7D022;
    ejectionAddress = 0xd751600cBeA0598E3EFE363c6a8f85c5fe18E43D;

  }

  function getVoters() view external returns (address[]){
    return addresses;
  }

  function getIdentities() view external returns (bytes32[]) {
    return identities;
  }

  function proposeNewMoon(address mAddress, MoonType moonType) public  {
    
    if ((block.timestamp - proposedMoons[proposedMoonsIndex[0]].timeAdded) > 172800) {

      delete proposedMoons[proposedMoonsIndex[0]];
      delete proposedMoonsIndex[0];

      }

    if (proposedMoonsIndex.length >= 1000) {
      return;
      }

      proposedMoons[mAddress] = NewMoon(block.timestamp, moonType, 1);
      proposedMoonsIndex.push(mAddress);
      emit NewMoonProposed(mAddress);

  }


  function supportNewMoon(address newMoonAddress) public {

    NewMoon storage newMoon = proposedMoons[newMoonAddress];

    if (!newMoon.supportMap[msg.sender]) {
      newMoon.supportMap[msg.sender] = true;
      newMoon.votes++;
      proposedMoons[newMoonAddress] = newMoon;
    }

    uint quotient = (newMoon.votes*100)/addresses.length;

    if (quotient >= 67) {
    
      replaceNewMoon(newMoon, newMoonAddress);
    }

  }

  function replaceNewMoon(NewMoon newMoon, address newMoonAddress) internal {

      if (newMoon.moonType == MoonType.Verification) {
       verificationAddress = newMoonAddress;
      }

      else if (newMoon.moonType == MoonType.Ejection) {
        ejectionAddress = newMoonAddress;
      }

      delete proposedMoons[newMoonAddress]; 

  }

  function proposeEjection(address proposedAddress, bytes32 proof) public {

    ejectionContract = EjectionMoon(ejectionAddress);
    ejectionContract.propose(proposedAddress, proof, addresses, identities);

  }

  function proposeVoter(bytes32 proof) public {

    verificationContract = VerificationMoon(verificationAddress);
    verificationContract.propose(msg.sender, proof, addresses, identities);

  }

  function addVoter(address voterAddress, address verifierAddress, bytes32 identity) external {
    
    if (msg.sender != verificationAddress)
      return;

    addresses.push(voterAddress);
    identities.push(identity);
    voterMap[voterAddress] = identity;

    tokenContract = MBLToken(tokenAddress);
    tokenContract.transfer(voterAddress, newVoterAllocation());
    tokenContract.transfer(verifierAddress, verifierAllocation());
    lastVerified = voterAddress;

    emit NewVoter(voterAddress, identity);

  }

  function getBalance() public returns (uint256) {
        tokenContract = MBLToken(tokenAddress);            
        return tokenContract.balanceOf(this);
    }

    function verifierAllocation() internal returns (uint) {
     
      uint contractBalance = getBalance();
      return (-contractBalance*addresses.length/100000000000 + 2*contractBalance/10000000000)*1/5;

    }

  function newVoterAllocation() internal returns (uint) {
            uint contractBalance = getBalance();
           if (addresses.length < 1000000) {runLottery(contractBalance); }

      return (-contractBalance*addresses.length/100000000000 + 2*contractBalance/10000000000)*4/5;

  }

  function runLottery(uint contractBalance) internal {

            bytes32 blockHash = block.blockhash(block.number);
            bytes32 randomHash = keccak256(lastVerified, blockHash);
            uint hashNumber = uint(randomHash);
     
        if (addresses.length < 1000 && hashNumber < 2**246) {
             tokenContract = MBLToken(tokenAddress);
             tokenContract.transfer(lastVerified, contractBalance/5);
        }
        else if (hashNumber < 2**236)  {
             tokenContract = MBLToken(tokenAddress);
             tokenContract.transfer(lastVerified, contractBalance/5);
       }

  }

  function ejectVoter(address ejectedAddress, uint arrayIndex) external {
    
    if (msg.sender != ejectionAddress)
      return;

    if (addresses[arrayIndex] != ejectedAddress)
      return;

      delete addresses[arrayIndex];
      delete identities[arrayIndex];
      delete voterMap[ejectedAddress];
      emit EjectedVoter(ejectedAddress);

  }

}


 contract MBLToken {
    function transfer(address _to, uint256 _value) public;
    function balanceOf(address _tokenOwner) external view returns (uint balance);

 }

interface VerificationMoon  {

    function propose(address selfProposed, bytes32 argument, address[] addresses, bytes32[] identities) external;

}

interface EjectionMoon {

    function propose(address proposed, bytes32 argument, address[] addresses, bytes32[] identities) external;

}



