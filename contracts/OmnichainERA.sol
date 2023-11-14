// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import "./ERA.sol";

contract OmnichainERA is zContract {
    SystemContract public immutable systemContract;
    uint256 constant BITCOIN = 18332;
    ERA public eraContract;

    mapping(address => address) public beneficiary; // for bitcoin

    // Events for Bitcoin call
    event BitcoinCrossChainCall__0(uint8 action, uint8 value);
    event BitcoinCrossChainCall__1(
        address indexed beneficiary,
        uint8 action,
        address nftAddress,
        uint64 tokenId,
        address paymentToken,
        uint64 ask
    );
    event BitcoinCrossChainCall__2(
        address indexed beneficiary,
        uint8 action,
        uint64 listId
    );
    event BitcoinCrossChainCall__3(
        address indexed beneficiary,
        uint8 action,
        uint64 listId,
        address paymentTokenAddress,
        uint64 ask
    );
    event BitcoinCrossChainCall__4(
        address indexed beneficiary,
        uint8 action,
        uint64 listId
    );
    event BitcoinCrossChainCall__5(
        address indexed beneficiary,
        uint8 action,
        uint64 listId,
        address paymentTokenAddress,
        uint64 offerPrice
    );
    event BitcoinCrossChainCall__6(
        address indexed beneficiary,
        uint8 action,
        uint64 listId,
        uint64 offerId
    );
    event BitcoinCrossChainCall__7(
        address indexed beneficiary,
        uint8 action,
        uint64 listId,
        uint64 offerId
    );
    event BitcoinCrossChainCall__244(address indexed beneficiary, uint8 action);
    event BitcoinCrossChainCall__255(
        address indexed beneficiary,
        uint8 action,
        address indexed caller
    );

    // Events for Evm calls
    event EVMChainCall__0(address indexed caller, uint8 action, uint8 value);
    event EVMChainCall__1(
        address indexed caller,
        uint8 action,
        address nftAddress,
        uint64 tokenId,
        address paymentToken,
        uint64 ask
    );
    event EVMChainCall__2(address indexed caller, uint8 action, uint64 listId);
    event EVMChainCall__3(
        address indexed caller,
        uint8 action,
        uint64 listId,
        address paymentTokenAddress,
        uint64 ask
    );
    event EVMChainCall__4(address indexed caller, uint8 action, uint64 listId);
    event EVMChainCall__5(
        address indexed caller,
        uint8 action,
        uint64 listId,
        address paymentTokenAddress,
        uint64 offerPrice
    );
    event EVMChainCall__6(
        address indexed caller,
        uint8 action,
        uint64 listId,
        uint64 offerId
    );
    event EVMChainCall__7(
        address indexed caller,
        uint8 action,
        uint64 listId,
        uint64 offerId
    );
    event EVMChainCall__244(address indexed caller, uint8 action);

    // modifier
    modifier onlySystem() {
        require(
            msg.sender == address(systemContract),
            "Only system contract can call this function"
        );
        _;
    }

    constructor(address systemContractAddress, address _eraContractAddress) {
        systemContract = SystemContract(systemContractAddress);
        eraContract = ERA(_eraContractAddress);
    }

    function bytesToUint64(
        bytes calldata data,
        uint256 offset
    ) public pure returns (uint64 output) {
        bytes memory b = data[offset:offset + 8];
        assembly {
            output := mload(add(b, 8))
        }
    }

    function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external virtual override onlySystem {
        require(message.length > 0, "Empty message");

        address _caller = BytesHelperLib.bytesToAddress(context.origin, 0);
        uint8 action;

        if (context.chainID == BITCOIN) {
            address beneficiaryAddr = beneficiary[_caller];

            action = uint8(message[0]);

            if (action == 1) {
                address _nftAddress = BytesHelperLib.bytesToAddress(message, 1);
                uint64 _tokenId = bytesToUint64(message, 21);
                address _paymentTokenAddress = BytesHelperLib.bytesToAddress(
                    message,
                    29
                );
                uint64 _ask = bytesToUint64(message, 49);

                eraContract.list(
                    beneficiaryAddr,
                    _nftAddress,
                    _tokenId,
                    _paymentTokenAddress,
                    _ask
                );

                emit BitcoinCrossChainCall__1(
                    beneficiaryAddr,
                    action,
                    _nftAddress,
                    _tokenId,
                    _paymentTokenAddress,
                    _ask
                );
            } else if (action == 2) {
                uint64 listId = bytesToUint64(message, 1);

                eraContract.delist(beneficiaryAddr, listId);
                emit BitcoinCrossChainCall__2(beneficiaryAddr, action, listId);
            } else if (action == 3) {
                uint64 _listId = bytesToUint64(message, 1);
                address _paymentTokenAddress = BytesHelperLib.bytesToAddress(
                    message,
                    9
                );
                uint64 _ask = bytesToUint64(message, 29);

                eraContract.changePrice(
                    beneficiaryAddr,
                    _listId,
                    _paymentTokenAddress,
                    _ask
                );
                emit BitcoinCrossChainCall__3(
                    beneficiaryAddr,
                    action,
                    _listId,
                    _paymentTokenAddress,
                    _ask
                );
            } else if (action == 4) {
                uint64 _listId = bytesToUint64(message, 1);

                eraContract.buy(beneficiaryAddr, _listId);
                emit BitcoinCrossChainCall__4(beneficiaryAddr, action, _listId);
            } else if (action == 5) {
                uint64 _listId = bytesToUint64(message, 1);
                address _paymentTokenAddress = BytesHelperLib.bytesToAddress(
                    message,
                    9
                );
                uint64 _offerPrice = bytesToUint64(message, 29);

                eraContract.makeOffer(
                    beneficiaryAddr,
                    _listId,
                    _paymentTokenAddress,
                    _offerPrice
                );
                emit BitcoinCrossChainCall__5(
                    beneficiaryAddr,
                    action,
                    _listId,
                    _paymentTokenAddress,
                    _offerPrice
                );
            } else if (action == 6) {
                uint64 _listId = bytesToUint64(message, 1);
                uint64 _offerId = bytesToUint64(message, 9);

                eraContract.acceptOffer(beneficiaryAddr, _listId, _offerId);
                emit BitcoinCrossChainCall__6(
                    beneficiaryAddr,
                    action,
                    _listId,
                    _offerId
                );
            } else if (action == 7) {
                uint64 _listId = bytesToUint64(message, 1);
                uint64 _offerId = bytesToUint64(message, 9);

                eraContract.removeOffer(beneficiaryAddr, _listId, _offerId);
                emit BitcoinCrossChainCall__7(
                    beneficiaryAddr,
                    action,
                    _listId,
                    _offerId
                );
            } else if (action == 244) {
                eraContract.mintNFT(beneficiaryAddr);
                emit BitcoinCrossChainCall__244(beneficiaryAddr, action);
            } else if (action == 255) {
                beneficiary[_caller] = BytesHelperLib.bytesToAddress(
                    message,
                    1
                );
                emit BitcoinCrossChainCall__255(
                    beneficiary[_caller],
                    action,
                    _caller
                );
            } else {
                revert("Unknown action");
            }
        } else {
            (action) = abi.decode(message, (uint8));

            if (action == 1) {
                (
                    ,
                    address nftAddress,
                    uint64 tokenId,
                    address paymentToken,
                    uint64 ask
                ) = abi.decode(
                        message,
                        (uint8, address, uint64, address, uint64)
                    );

                eraContract.list(
                    _caller,
                    nftAddress,
                    tokenId,
                    paymentToken,
                    ask
                );
                emit EVMChainCall__1(
                    _caller,
                    action,
                    nftAddress,
                    tokenId,
                    paymentToken,
                    ask
                );
            } else if (action == 2) {
                (, uint64 listId) = abi.decode(message, (uint8, uint64));

                eraContract.delist(_caller, listId);
                emit EVMChainCall__2(_caller, action, listId);
            } else if (action == 3) {
                (, uint64 listId, address payementToken, uint64 ask) = abi
                    .decode(message, (uint8, uint64, address, uint64));

                eraContract.changePrice(_caller, listId, payementToken, ask);
                emit EVMChainCall__4(_caller, action, listId);
            } else if (action == 4) {
                (, uint64 listId) = abi.decode(message, (uint8, uint64));

                eraContract.buy(_caller, listId);
                emit EVMChainCall__4(_caller, action, listId);
            } else if (action == 5) {
                (, uint64 listId, address paymentToken, uint64 offerPrice) = abi
                    .decode(message, (uint8, uint64, address, uint64));

                eraContract.makeOffer(
                    _caller,
                    listId,
                    paymentToken,
                    offerPrice
                );
                emit EVMChainCall__5(
                    _caller,
                    action,
                    listId,
                    paymentToken,
                    offerPrice
                );
            } else if (action == 6) {
                (, uint64 listId, uint64 offerId) = abi.decode(
                    message,
                    (uint8, uint64, uint64)
                );

                eraContract.acceptOffer(_caller, listId, offerId);
                emit EVMChainCall__6(_caller, action, listId, offerId);
            } else if (action == 7) {
                (, uint64 listId, uint64 offerId) = abi.decode(
                    message,
                    (uint8, uint64, uint64)
                );

                eraContract.removeOffer(_caller, listId, offerId);
                emit EVMChainCall__7(_caller, action, listId, offerId);
            } else if (action == 244) {
                eraContract.mintNFT(_caller);
                emit EVMChainCall__244(_caller, action);
            } else {
                revert("Unknown function action");
            }
        }
    }
}
