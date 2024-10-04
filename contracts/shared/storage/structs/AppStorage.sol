// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "../../libraries/LibEnumerableSet.sol";
import {UintQueueLibrary} from "../../libraries/LibUintQueueLibrary.sol";
import {UserType, EquipmentType} from "./NftStorage.sol";

using EnumerableSet for EnumerableSet.UintSet;
using UintQueueLibrary for UintQueueLibrary.UintQueue;

struct User {
    string userId;
    uint nftId;
    address reciveAddress;
    address delegateEOA;
    UserType userType;
    //
    string refferalId;
    uint refferalCount;
}
struct DelegateEOA {
    uint userIndex;
    string userId;
    address connectAddress;
    bool isOwnNFT;
}

struct levelInfo {
    uint level;
    uint requireExp;
    uint levelUserCount;
    uint heartMax;
}

struct ElementaNFT {
    address ownerAddress;
    address delegateAddress;
    string nickName;
    uint grade;
    uint level;
    uint exp;
    uint heartMax;
    uint heartPoint;
    uint plusHeartPoint;
    uint updateHeartTime;
    uint elementaPoint;
    // from VRF, origin random value
    uint originRandomValue;
    // uint[10] _gap;
    // uint[10] equipmentItem;
}

struct MysteryBox {
    uint boxId;
    uint uniqValue;
}
struct ElementaItem {
    EquipmentType equipmentType;
    uint itemId;
    string name;
    string svgUri;
    string animateColors;
    string stopColor;
    string animateDuration;
}

struct ElementaToken {
    uint phaseMaxSupply;
    uint mintedSupply;
}

struct OraklVRF {
    bytes32 keyHash;
    uint64 accId;
    uint32 callbackGasLimit;
    uint32 numWords;
}

struct AppStorage {
    mapping(string => address) contracts;
    mapping(string => User) users;
    uint globalUserIndex;
    mapping(string => uint) userIndex;
    // delegate EOA Info
    mapping(address => DelegateEOA) delegateEOAs;
    // NFT Info
    // nftId(userIndex) => ElementaNFT
    mapping(uint => ElementaNFT) elementaNFTs;
    mapping(uint => levelInfo) levelInfos;
    mapping(address => bool) isDelegateEOA;
    //
    // items info
    mapping(uint => ElementaItem) elementaItems;
    //
    // nftId => item info
    mapping(uint => uint[10]) equipItems;
    mapping(uint => ElementaToken) elementaToken;
    // Orakl VRF
    OraklVRF oraklVRF;

    mapping(uint => MysteryBox) mysteryBoxes;

    
    // SVGs
    // mapping(uint => GradeOutline) gradeOutlines;
    // mapping(uint => BackGround) backgrounds;
}
