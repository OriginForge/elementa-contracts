// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {VRFConsumerBase} from "@bisonai/orakl-contracts/v0.1/src/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/v0.1/src/interfaces/IVRFCoordinator.sol";

contract VRFConsumer is VRFConsumerBase {

    struct userRandomValue {
        uint256 requestId;
        uint8 tryIndex;
    }

    IVRFCoordinator COORDINATOR;
    uint64 public sAccountId;
    bytes32 public sKeyHash;
    uint32 public sCallbackGasLimit = 300000;
    uint32 public sNumWords = 6;
    
    mapping(address => bool) public isOwner;
    // userId > userRandomValue Struct
    mapping(string => userRandomValue) public userIdToRequestId;
    mapping(uint => string) public requestIdToUserId;
    // reqKey > randomValue
    mapping(uint => mapping(uint => uint)) public resRandomValues;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    constructor(
        uint64 accountId,
        address coordinator,
        bytes32 keyHash
    ) VRFConsumerBase(coordinator) {
        COORDINATOR = IVRFCoordinator(coordinator);
        sAccountId = accountId;
        sKeyHash = keyHash;
        isOwner[msg.sender] = true;
    }

    function setOwner(address _owner) public onlyOwner {
        isOwner[_owner] = true;
    }

    function setAccountId(uint64 accountId) public onlyOwner {
        sAccountId = accountId;
    }

    function setKeyHash(bytes32 keyHash) public onlyOwner {
        sKeyHash = keyHash;
    }

    function setCallbackGasLimit(uint32 callbackGasLimit) public onlyOwner {
        sCallbackGasLimit = callbackGasLimit;
    }

    function requestRandomWords() internal returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            sKeyHash,
            sAccountId,
            sCallbackGasLimit,
            sNumWords
        );
    }

    function elementaVRFCall(string memory _userId) public onlyOwner returns(uint) {
        uint requestId = requestRandomWords();

        requestIdToUserId[requestId] = _userId;

        if(userIdToRequestId[_userId].tryIndex == 0) {
        uint randomHash = uint(keccak256(abi.encodePacked(block.timestamp, requestId, msg.sender)));
        uint randomNumber = uint(randomHash % 64) + 1;
        userIdToRequestId[_userId].tryIndex ++;
        return randomNumber;
        }
        if(userIdToRequestId[_userId].tryIndex >= 5 ){
            userIdToRequestId[_userId].tryIndex = 1;
        }
        return resRandomValues[userIdToRequestId[_userId].requestId][userIdToRequestId[_userId].tryIndex];

        

    }

    function fulfillRandomWords(
        uint256 requestId /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        userIdToRequestId[requestIdToUserId[requestId]].requestId = requestId;
        
        for(uint i = 0; i < sNumWords; i++){
            resRandomValues[requestId][i] = (randomWords[i] % 64 )+ 1;
        }
        userIdToRequestId[requestIdToUserId[requestId]].tryIndex ++;        
    }

}
