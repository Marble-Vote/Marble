pragma solidity ^0.4.24;
// We have to specify what version of compiler this code will compile with

contract LotteryMoon {

  MarbleEarth public earthContract = MarbleEarth(0x3DADd4EC1a4Cfc1D035cD6C65262D06294Fe626b);

  address public earthAddress = 0x3DADd4EC1a4Cfc1D035cD6C65262D06294Fe626b;
  address public lastVerified;
  address public lastVerifier;

  uint public lastBlockNumber = 0;
  uint lotteryCoefficient = 0;

  function sentByEarthAddress() view public returns (bool) {
      if (msg.sender == earthAddress) {
        return true;
      }
      return false;
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

  function enterLottery(address voterAddress, address verifierAddress) external {
  
    if (!sentByEarthAddress())
      return;

      submitToLottery(voterAddress);
      sumbitToLottery(verifierAddress);
   
  }

  function bytesToInt(bytes32 bytesForConversion) pure public returns (uint) {
            return uint(bytesForConversion);
  }

  function getHash(address entrantAddress, bytes32 hash2) pure public returns (bytes32) {

    return keccak256(abi.encodePacked(entrantAddress, hash2));
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

  function getLotteryCoefficient() view public returns (uint) {
    return lotteryCoefficient;
  }

  function winsLottery(address entrantAddress) view public returns (bool) {
       if (isNumberSmaller(bytesToInt(getHash(entrantAddress, blockhash(lastBlockNumber))), 2**(246 - lotteryCoefficient))) {
        return true;
       }
       return false;
  }

  function submitToLottery(address entrantAddress) public {

   if (winsLottery(entrantAddress)) {
          rewardLotteryWinner(entrantAddress);
          lotteryCoefficient = lotteryCoefficient + 2; 
           }
  }

  function rewardLotteryWinner(address winnerAddress) public returns (bytes32) {
             earthContract.rewardLotteryWinner(winnerAddress);
  }

}

//before update: 

contract MBLToken {
  function transfer(address _to, uint256 _value) public;
  function balanceOf(address _tokenOwner) external view returns (uint balance);
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
 }


