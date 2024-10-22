// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IOraklVRF {
    function sRandomWords() external view returns (uint256);
    function VRFCall(
        bytes32 keyHash,
        uint64 accId,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint[] memory);
    function requestRandomWords(bytes32 keyHash,
        uint64 accId,
        uint32 callbackGasLimit,
        uint32 numWords) external returns(uint);


}
