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
        s.delegateEOAs[msg.sender].connectAddress = _address;

        // s.elementaNFTs[s.delegateEOAs[msg.sender].userIndex].originRandomValue = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        s.elementaNFTs[s.delegateEOAs[msg.sender].userIndex].originRandomValue = LibVRF.reqVRF(1)[0];
        s.elementaNFTs[s.delegateEOAs[msg.sender].userIndex].ownerAddress = _address;

        IERC721(s.contracts["nft"]).diamondMint(
            _address,
            s.delegateEOAs[msg.sender].userIndex
        );

        IERC721(s.contracts["nft"])._update_metadata_uri(s.delegateEOAs[msg.sender].userIndex);        
 
        // refferal transfer
        // token transfer(ref, amount)

        emit RegisterAddress(_address, s.delegateEOAs[msg.sender].userIndex);
    }
    

    // function testVRF_mint() external {
    //     s.users[s.delegateEOAs[msg.sender].userId].reciveAddress = msg.sender;

    //     s.delegateEOAs[msg.sender].isOwnNFT = true;
    //     s.delegateEOAs[msg.sender].connectAddress = msg.sender;

    //     s.elementaNFTs[7].originRandomValue = LibVRF.reqVRF(1)[0];
    //     s.elementaNFTs[7].ownerAddress = msg.sender;

    //     // IERC721(s.contracts["nft"]).diamondMint(
    //     //     msg.sender,
    //     //     6
    //     // );

    //     IERC721(s.contracts["nft"])._update_metadata_uri(7);        
 
    //     // emit RegisterAddress(msg.sender, 6);
    //     //    s.globalUserIndex++;
    //     // refferal transfer
    //     // token transfer(ref, amount)

    // }

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

    function user_getNftInfoById(string memory _userId) external view returns (uint,ElementaNFT memory) {
        uint nftId = s.userIndex[_userId];
        ElementaNFT memory userNFT = s.elementaNFTs[nftId];
        return (nftId, userNFT);
    }

    function user_getDelegateInfo(
        address _address
    ) external view returns (DelegateEOA memory) {
        DelegateEOA memory delegate = s.delegateEOAs[_address];
        return delegate;
    }
}
