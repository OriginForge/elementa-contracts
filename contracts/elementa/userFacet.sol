// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import {IERC721} from "../shared/interfaces/IERC721.sol";
import {User, ElementaNFT, DelegateEOA} from "../shared/storage/structs/AppStorage.sol";
import {LibVRF} from "../shared/libraries/LibVRF.sol";

contract userFacet is modifiersFacet {
    event RegisterAddress(address indexed _address, uint indexed _nftId);

    function user_inputAddress(
        address _address
    ) external onlyDelegateEOA onlyEOA(_address) {
        s.users[s.delegateEOAs[msg.sender].userId].reciveAddress = _address;

        s.delegateEOAs[msg.sender].isOwnNFT = true;

        // NFT mint to user
        IERC721(s.contracts["nft"]).diamondMint(
            _address,
            s.delegateEOAs[msg.sender].userIndex
        );
        
        s.elementaNFTs[s.delegateEOAs[msg.sender].userIndex].originRandomValue = LibVRF.reqVRF(0)[0];
 
        // refferal transfer
        // token transfer(ref, amount)

        emit RegisterAddress(_address, s.delegateEOAs[msg.sender].userIndex);
    }

    function user_getUserInfo(
        string memory _userId
    ) external view returns (User memory) {
        User memory user = s.users[_userId];
        return user;
    }

    function user_getNftInfo(
        uint _nftId
    ) external view returns (ElementaNFT memory) {
        ElementaNFT memory userNFT = s.elementaNFTs[_nftId];
        return userNFT;
    }

    function user_getDelegateInfo(
        address _address
    ) external view returns (DelegateEOA memory) {
        DelegateEOA memory delegate = s.delegateEOAs[_address];
        return delegate;
    }
}
