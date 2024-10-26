// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {IERC721} from "../shared/interfaces/IERC721.sol";
import {IERC20} from "../shared/interfaces/IERC20.sol";
import {User,ElementaToken, ElementaNFT, DelegateEOA} from "../shared/storage/structs/AppStorage.sol";
import {UintQueueLibrary} from "../shared/libraries/LibUintQueueLibrary.sol";
import {LibVRF} from "../shared/libraries/LibVRF.sol";
import {IOraklVRF} from "../shared/interfaces/IOraklVRF.sol";

contract botMiniGameFacet is modifiersFacet {
    using UintQueueLibrary for UintQueueLibrary.UintQueue;
    /**
     * @notice token preDistribution functions
     */

    event playDiceEvent(string indexed userId, uint indexed result);
    event playRouletteEvent(string indexed userId, uint indexed result);
    event widthdrawElementaToken(
        address indexed userAddress,
        uint indexed amount
    );
    event userUpgrade(string indexed userId, uint indexed elementaId,uint indexed userLevel);

    function getElementa20Info() public view returns (uint, uint, uint) {}

    function calculateHeartPoint(uint _nftId) public view returns (uint) {
        ElementaNFT memory nft = s.elementaNFTs[_nftId];
        if (nft.heartPoint == nft.heartMax) {
            return nft.heartPoint;
        }

        uint elapsedTime = block.timestamp - nft.updateHeartTime;
        uint pointToAdd = elapsedTime / 30 minutes;

        if (nft.heartPoint + pointToAdd >= nft.heartMax) {
            return nft.heartMax;
        } else {
            return nft.heartPoint + pointToAdd;
        }
    }

    function calculateHeartTime(uint _nftId) external view returns (uint) {
        ElementaNFT memory nft = s.elementaNFTs[_nftId];

        uint elapsedTime = block.timestamp - nft.updateHeartTime;
        uint pointToAdd = elapsedTime / 30 minutes;

        if (nft.heartPoint + pointToAdd >= nft.heartMax) {
            return 0;
        } else {
              uint nextHeartTime = 30 minutes -
            (elapsedTime - (pointToAdd * 30 minutes));
        return nextHeartTime;
        }
    }

    function _updateHeartPoints(uint _nftId) internal {
        ElementaNFT storage nft = s.elementaNFTs[_nftId];

        nft.heartPoint = calculateHeartPoint(_nftId);
        nft.updateHeartTime = block.timestamp;
    }

    // using orakl - VRF function
    function _generateResultVRF(uint _maxPoint) internal view returns (uint) {
        //
        //
    }

    // invitee user can increase heart point
    function _increaseHeart(uint _nftId) internal {
        ElementaNFT storage nft = s.elementaNFTs[_nftId];
        _updateHeartPoints(_nftId);
        require(
            nft.delegateAddress == msg.sender,
            "only delegateEOA can increase heart"
        );

        if (nft.heartPoint == nft.heartMax) {
            nft.plusHeartPoint++;
        } else {
            nft.heartPoint++;
        }
    }

    function _increaseElementaPoint(uint _nftId, uint _point) internal {
        ElementaNFT storage nft = s.elementaNFTs[_nftId];
        nft.elementaPoint += _point;
    }

    


    function isLevelUp(string memory _userId) public view returns (bool) {
        
        uint currentLevel = s.elementaNFTs[s.userIndex[_userId]].level;
        uint currentExp = s.elementaNFTs[s.userIndex[_userId]].exp;
        uint maxLevel = 10;
        
        if(s.levelInfos[currentLevel+1].requireExp <= currentExp && maxLevel > currentLevel) {
            return true;
        }
        return false;
    }

    function elementaUpgrade(string memory _userId) external onlyDelegateEOA  {
        require(isLevelUp(_userId), "Not enough exp");
        IERC721 elementaNFT = IERC721(s.contracts["nft"]);
        
        uint nextLevel = s.elementaNFTs[s.userIndex[_userId]].level + 1;
        s.levelInfos[nextLevel].levelUserCount += 1;
        // s.levelInfos[nextLevel-1].levelUserCount -= 1;

        s.elementaNFTs[s.userIndex[_userId]].level = nextLevel;

        s.elementaNFTs[s.userIndex[_userId]].heartMax = s.levelInfos[nextLevel].heartMax;
        s.elementaNFTs[s.userIndex[_userId]].heartPoint = s.levelInfos[nextLevel].heartMax;
        s.elementaNFTs[s.userIndex[_userId]].updateHeartTime = block.timestamp;

        elementaNFT._update_metadata_uri(s.userIndex[_userId]);
        
        emit userUpgrade(_userId, s.userIndex[_userId], nextLevel);
    }



    function playDice(string memory _userId, uint _amount) external onlyDelegateEOA returns(uint){    
        _updateHeartPoints(s.userIndex[_userId]);
        ElementaToken storage token = s.elementaToken[1];
        ElementaNFT storage nft = s.elementaNFTs[s.userIndex[_userId]];
        require(
            nft.heartPoint > 0 ||
                nft.plusHeartPoint > 0 ,
            "Not enough heart points"
        );
        // require(
        // token.mintedSupply + (6 * 1e19) <
        //         token.phaseMaxSupply,
        //     "Not enough balance"
        // );

        if (nft.plusHeartPoint > 0) {
            nft.plusHeartPoint -= 1;
        } else {
            nft.heartPoint -= 1;
            nft.updateHeartTime = block.timestamp;
        }


        uint randomValue = LibVRF.resVRFDice(_userId);
        uint getReward = randomValue * 1e19;
        nft.exp += 10;
        nft.elementaPoint += getReward;
        token.mintedSupply += getReward;
        
        IERC721 elementaNFT = IERC721(s.contracts["nft"]);
        elementaNFT._update_metadata_uri(s.userIndex[_userId]);

        emit playDiceEvent(_userId, getReward);

        return getReward;
    }
    
    function playRoulette(string memory _userId, uint _amount) external onlyDelegateEOA returns(uint){    
        _updateHeartPoints(s.userIndex[_userId]);
        ElementaToken storage token = s.elementaToken[1];
        ElementaNFT storage nft = s.elementaNFTs[s.userIndex[_userId]];
        
        
    
        require(
            nft.heartPoint >= 3 ||
                nft.plusHeartPoint >= 3 ,
            "Not enough heart points"
        );
        // require(
        // token.mintedSupply + (64 * 1e19) <
        //         token.phaseMaxSupply,
        //     "Not enough balance"
        // );

        if (nft.plusHeartPoint > 3) {
            nft.plusHeartPoint -= 3;
        } else {
            nft.heartPoint -= 3;
            nft.updateHeartTime = block.timestamp;
        }

        // min 1 ~ 64 random value
        uint randomValue = LibVRF.resVRFRoulette(_userId);

        uint getReward = randomValue * 1e19;
        
        nft.exp += 30;
        nft.elementaPoint += getReward;
        token.mintedSupply += getReward;
        
        IERC721 elementaNFT = IERC721(s.contracts["nft"]);
        elementaNFT._update_metadata_uri(s.userIndex[_userId]);

        emit playRouletteEvent(_userId, getReward);

        return getReward;
    }

    

}
