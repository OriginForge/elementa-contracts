// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AppStorage} from "../storage/facets/AppStorageFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IOraklVRF} from "../interfaces/IOraklVRF.sol";

library LibVRF {
    
    address constant VRF_ORAKL = address(0x2974e0bF1a353EB0cB1a7093f1754854dB3ff5a7);
    bytes32 constant VRF_KEYHASH = 0x6cff5233743b3c0321a19ae11ab38ae0ddc7ddfe1e91b162fa8bb657488fb157;

    function reqVRF(uint32 _numbWords) internal returns (uint[] memory) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL);
        return oraklVRF.VRFCall(
            VRF_KEYHASH,
            28,
            200000,
            _numbWords
        );
    }

    function resVRF() internal view returns (uint[] memory) {
        IOraklVRF oraklVRF = IOraklVRF(VRF_ORAKL);
        return oraklVRF.sRandomWords();
     
    }
}