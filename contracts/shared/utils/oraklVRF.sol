// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {VRFConsumerBase} from "@bisonai/orakl-contracts/v0.1/src/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/v0.1/src/interfaces/IVRFCoordinator.sol";

contract VRFConsumer is VRFConsumerBase {

    IVRFCoordinator COORDINATOR;
    uint64 public sAccountId;
    bytes32 public sKeyHash;
    uint32 public sCallbackGasLimit = 300000;
    uint32 public sNumWords = 5;
    
    mapping(address => bool) public isOwner;
    mapping(uint => string) public requestIdToUserId;
    mapping(uint => uint[5]) public requestIdToRandomWords;
    
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

    function elementaVRFCall(string memory _userId) public onlyOwner  {
        uint requestId = requestRandomWords();
        requestIdToUserId[requestId] = _userId;
    }

    function fulfillRandomWords(
        uint256 requestId /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        for(uint i = 0; i < randomWords.length; i++) {
            requestIdToRandomWords[requestId][i] = (randomWords[i] % 64 )+ 1;
        }    
    }



}
