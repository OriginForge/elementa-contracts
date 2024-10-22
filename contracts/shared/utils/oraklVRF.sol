// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {VRFConsumerBase} from "@bisonai/orakl-contracts/v0.1/src/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/v0.1/src/interfaces/IVRFCoordinator.sol";

contract VRFConsumer is VRFConsumerBase {
    uint256[] public sRandomWords; // 여러 개의 랜덤 값을 배열로 저장
    address public diamondContract;
    address public sOwner;

    IVRFCoordinator COORDINATOR;

    modifier onlyOwner() {
        require(
            msg.sender == sOwner || msg.sender == diamondContract,
            "not owner"
        );
        _;
    }

    constructor(
        address coordinator,
        address _diamond
    ) VRFConsumerBase(coordinator) {
        sOwner = msg.sender;
        COORDINATOR = IVRFCoordinator(coordinator);
        diamondContract = _diamond;
    }

    // Receive remaining payment from requestRandomWordsPayment
    receive() external payable {}

    function editDiamond(address _diamondAddress) public onlyOwner {
        diamondContract = _diamondAddress;
    }

    function requestRandomWords(
        bytes32 keyHash,
        uint64 accId,
        uint32 callbackGasLimit,
        uint32 numWords
    ) public onlyOwner returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            accId,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        // 배열에 여러 랜덤 값을 저장
        sRandomWords = randomWords;
    }

    function VRFCall(
        bytes32 keyHash,
        uint64 accId,
        uint32 callbackGasLimit,
        uint32 numWords
    ) public onlyOwner returns (uint[] memory) {
        requestRandomWords(keyHash, accId, callbackGasLimit, numWords);
        return sRandomWords;
    }
}
