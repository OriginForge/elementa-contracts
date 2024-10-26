// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IOraklVRF {
    struct userRandomValue{ 
        uint requestId;
        uint8 tryIndex;
    }

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

    // Roulette
    function elementaVRFCall(string memory _userId) external returns(uint);
    function userIdToRequestId(string memory) external view returns(userRandomValue memory); 
    function resRandomValues(uint _requestKey, uint _index) external view returns(uint);

}
