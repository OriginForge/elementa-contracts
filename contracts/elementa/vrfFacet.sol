// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBase} from "@bisonai/orakl-contracts/src/v0.1/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IVRFCoordinator.sol";


contract RoulletVRF is
    Ownable,
    VRFConsumerBase
{
    
    IVRFCoordinator COORDINATOR;
    // Your subscription ID.
    uint64 public sAccountId;

    bytes32 public sKeyHash;

    // function.
    uint32 sCallbackGasLimit = 300000;

    uint32 sNumWords = 2;


    mapping(string => uint) public requestIdToUserId;
    mapping(string => uint) public userIdToRoulleteValue;
    mapping(string => uint) public userIdToDiceValue;
    

    event SetAccountId(uint64 accId);
    

    constructor(
        uint64 accountId,
        address coordinator,
        bytes32 keyHash    
    )
    
        VRFConsumerBase(coordinator)
        Ownable(msg.sender)
    {
    
        COORDINATOR = IVRFCoordinator(coordinator);
        sAccountId = accountId;
        sKeyHash = keyHash;
    }

    
    function setAccountId(uint64 accId) public onlyOwner {
        sAccountId = accId;
        emit SetAccountId(accId);
    }

    function setKeyHash(bytes32 newHash) public onlyOwner {
        sKeyHash = newHash;
    }

    function setGasLimit(uint32 newGas) public onlyOwner {
        sCallbackGasLimit = newGas;
    }

    function requestRandomWords() internal returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            sKeyHash,
            sAccountId,
            sCallbackGasLimit,
            sNumWords
        );
    }

    function TestCaller(string memory _userId) public {
        uint256 requestId = requestRandomWords() 

    }

    function fulfillRandomWords(
        uint256 requestId /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        string memory _userId = requestIdToUserId[requestId];

        uint rouletteValue = ((randomWords[0]%64) + 1) * 1e19;
        userIdToRoulleteValue[_userId] = rouletteValue;
        

        uint diceValue = ((randomWords[1]%6) + 1) * 1e19;
        userIdToDiceValue[_userId] = diceValue;
    }

    
    // Receive remaining payment from requestRandomWordsPayment
    receive() external payable {}
}