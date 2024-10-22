// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {UserType, User, EquipmentType, ElementaItem, ElementaNFT, DelegateEOA, levelInfo} from "../shared/storage/structs/AppStorage.sol";
import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {LibVRF} from "../shared/libraries/LibVRF.sol";


contract adminFacet is modifiersFacet {
    using Strings for *;

    event RegisterUser(
        UserType indexed _type,
        string indexed userId,
        uint indexed userIndex
    );

    function setContract(
        string memory _name,
        address _address
    ) external onlyAdmin {
        s.contracts[_name] = _address;
    }

    function getContract(string memory _name) external view returns (address) {
        return s.contracts[_name];
    }

    // User Registration
    function admin_registerMessengerUser(
        UserType _type,
        string memory _userId,
        address _delegateEOA,
        string memory _refferalId
    ) external onlyAdmin {
        string memory userId = lower(_userId);

        require(
            s.users[userId].delegateEOA == address(0),
            "admin_registerMessengerUser: user already registered"
        );

        s.users[userId].userId = userId;
        s.users[userId].userType = _type;
        s.users[userId].delegateEOA = _delegateEOA;
        s.users[userId].refferalId = _refferalId;
        s.users[_refferalId].refferalCount++;
        s.users[userId].nftId = s.globalUserIndex;
        s.userIndex[userId] = s.globalUserIndex;

        s.elementaNFTs[s.globalUserIndex].level = 1;
        s.elementaNFTs[s.globalUserIndex].heartMax = 5;
        s.elementaNFTs[s.globalUserIndex].heartPoint = 5;
        s.elementaNFTs[s.globalUserIndex].updateHeartTime = block.timestamp;
        s.elementaNFTs[s.globalUserIndex].delegateAddress = _delegateEOA;
        

        s.delegateEOAs[_delegateEOA].userIndex = s.globalUserIndex;
        s.delegateEOAs[_delegateEOA].userId = userId;

        s.levelInfos[1].levelUserCount++;

        s.isDelegateEOA[_delegateEOA] = true;

        emit RegisterUser(_type, userId, s.userIndex[userId]);

        s.globalUserIndex++;
    }

    function admin_vrfSettings(bytes32 _keyHash, uint64 _accId, uint32 _callbackGasLimit) external onlyAdmin {
        s.oraklVRF.keyHash = _keyHash;
        s.oraklVRF.accId = _accId;
        s.oraklVRF.callbackGasLimit = _callbackGasLimit;
    }

    function admin_userMigration(string memory _userId, uint _level, uint _exp, uint _point, uint _heartMax) external onlyAdmin {
        s.elementaNFTs[s.userIndex[_userId]].level = _level;
        s.elementaNFTs[s.userIndex[_userId]].exp += _exp;
        s.elementaNFTs[s.userIndex[_userId]].elementaPoint += _point;
        s.elementaNFTs[s.userIndex[_userId]].heartMax = _heartMax;

        s.elementaToken[1].mintedSupply += _point;

    }

    function admin_setLevelInfo(uint _level, uint _requireExp, uint _heartMax) external onlyAdmin {
        s.levelInfos[_level].level = _level;
        s.levelInfos[_level].requireExp = _requireExp;
        s.levelInfos[_level].heartMax = _heartMax;
    }

    function admin_getLevelInfos(uint _level) external view returns (levelInfo memory) {
        return s.levelInfos[_level];
    }
    // function admin_registerWalletUser(address _delegateEOA) external onlyAdmin {
    //     string memory userId = lower(Strings.toHexString(msg.sender));

    //     s.users[userId].userId = userId;
    //     s.users[userId].userType = UserType.Wallet;
    //     s.users[userId].delegateEOA = _delegateEOA;
    //     s.userIndex[userId] = s.globalUserIndex;

    //     emit RegisterUser(UserType.Wallet, userId, s.userIndex[userId]);

    //     s.globalUserIndex++;
    // }

    // function admin_setBackgroundSvg(
    //     uint _class,
    //     string memory _animateColors,
    //     string memory _stopColor,
    //     string memory _animateDuration
    // ) external onlyAdmin {
    //     s.backgrounds[_class].animateColors = _animateColors;
    //     s.backgrounds[_class].stopColor = _stopColor;
    //     s.backgrounds[_class].animateDuration = _animateDuration;
    // }

    // function admin_setTierOutlineSvg(
    //     uint _class,
    //     string memory _animateColors,
    //     string memory _stopColor,
    //     string memory _animateDuration
    // ) external onlyAdmin {
    //     s.tierOutlines[_class].animateColors = _animateColors;
    //     s.tierOutlines[_class].stopColor = _stopColor;
    //     s.tierOutlines[_class].animateDuration = _animateDuration;
    // }

    // function admin_setEquipment(
    //     EquipmentType _itemType,
    //     uint _itemId,
    //     string memory _name,
    //     bytes memory _svgUri
    // ) external onlyAdmin {
    //     s.elementaItems[_itemType][_itemId].equipmentType = _itemType;
    //     s.elementaItems[_itemType][_itemId].itemId = _itemId;
    //     s.elementaItems[_itemType][_itemId].name = _name;
    //     s.elementaItems[_itemType][_itemId].svgUri = _svgUri;
    // }

    // function admin_getEquipment(
    //     EquipmentType _itemType,
    //     uint _itemId
    // ) external view returns (ElementaItem memory) {
    //     return s.elementaItems[_itemType][_itemId];
    // }

    //
    //
    //
    //
    // lower functions
    function _lower(bytes1 _b1) private pure returns (bytes1) {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }

    function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }


    // function fixDatas(string memory _userId, uint _index, address _delegateEOA, address _connectAddress) external onlyAdmin {
    //     User storage user = s.users[_userId];
    //     user.nftId = _index;
    //     user.delegateEOA = _delegateEOA;

    //     s.delegateEOAs[_delegateEOA].userIndex = _index;
    //     s.delegateEOAs[_delegateEOA].userId = _userId;
    //     s.delegateEOAs[_delegateEOA].connectAddress = _connectAddress;
    //     s.delegateEOAs[_delegateEOA].isOwnNFT = true;

    //     s.elementaNFTs[_index].ownerAddress = _connectAddress;
    //     s.elementaNFTs[_index].delegateAddress = _delegateEOA;
    // }

    

    
}




