// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage} from "../storage/facets/AppStorageFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IOraklVRF} from "../interfaces/IOraklVRF.sol";

library LibVRF {
    
    address constant VRF_ORAKL = address(0x2974e0bF1a353EB0cB1a7093f1754854dB3ff5a7);
    bytes32 constant VRF_KEYHASH = 0x6cff5233743b3c0321a19ae11ab38ae0ddc7ddfe1e91b162fa8bb657488fb157;
    address constant VRF_ORAKL_ROULETTE = address(0xA1b9Be3dEc8612e727564Baf46387c4366912d74);
    address constant VRF_ORAKL_DICE = address(0xF1A9564396F0d27FC61bA2E0E0938Dc0995D4223);

    function reqVRF(uint32 _numbWords) internal returns (uint[] memory) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL);
        return oraklVRF.VRFCall(
            VRF_KEYHASH,
            28,
            200000,
            _numbWords
        );
    }

    function resVRF() internal view returns (uint) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL_ROULETTE);
        return oraklVRF.sRandomWords();
     
    }

    function reqVRFRoulette() internal returns (uint) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL_ROULETTE);
        return oraklVRF.requestRandomWords(
            VRF_KEYHASH,
            28,
            200000,
            1
        );
    }

    function resVRFRoulette(string memory _userId) internal returns (uint) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL_ROULETTE);
        return oraklVRF.elementaVRFCall(_userId);
    }


    function resVRFDice(string memory _userId) internal returns (uint) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL_DICE);
        return oraklVRF.elementaVRFCall(_userId);
    }
}
 
