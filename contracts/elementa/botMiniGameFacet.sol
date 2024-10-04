// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {IERC721} from "../shared/interfaces/IERC721.sol";
import {User, ElementaNFT, DelegateEOA} from "../shared/storage/structs/AppStorage.sol";
import {UintQueueLibrary} from "../shared/libraries/LibUintQueueLibrary.sol";
import {LibVRF} from "../shared/libraries/LibVRF.sol";
import {IOraklVRF} from "../shared/interfaces/IOraklVRF.sol";

contract botMiniGameFacet is modifiersFacet {
    using UintQueueLibrary for UintQueueLibrary.UintQueue;
    /**
     * @notice token preDistribution functions
     */

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

    function calculateHeartTime(uint _nftId) public view returns (uint) {
        ElementaNFT memory nft = s.elementaNFTs[_nftId];

        uint elapsedTime = block.timestamp - nft.updateHeartTime;
        uint pointToAdd = elapsedTime / 30 minutes;

        if (nft.heartPoint + pointToAdd >= nft.heartMax) {
            return 0;
        } else {
            return 30 minutes - (elapsedTime * 30 minutes);
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

    function callVRF(uint32 _numbWords) public returns(uint[] memory){
        return LibVRF.reqVRF(_numbWords);

    }


}
