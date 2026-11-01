// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool private _nonReentrant;
    constructor() { _nonReentrant = false; }
    modifier nonReentrant() {
        require(!_nonReentrant, "ReentrancyGuard: reentrant call");
        _nonReentrant = true;
        _;
        _nonReentrant = false;
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _owner = msg.sender; emit OwnershipTransferred(address(0), _owner); }
    modifier onlyOwner() { require(_owner == msg.sender, "Ownable: caller is not the owner"); _; }
    function owner() public view returns (address) { return _owner; }
}

// FIX: minimal self-contained ERC721 face for escrow — the fraction is created
// by the NFT holder, who approves this contract and deposits the NFT here.
interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract NFTFractionalization is ReentrancyGuard, Ownable {
    struct Fraction {
        address nftContract;
        uint256 tokenId;
        address owner;
        uint256 totalShares;
        uint256 sharesSold;
        uint256 pricePerShare;
        bool active;
        bool claimed;
    }
    Fraction[] public fractions;
    mapping(address => uint256[]) public ownerFractions;
    mapping(uint256 => mapping(address => uint256)) public shares;
    uint256 public fractionCount;

    event FractionCreated(uint256 indexed fid, address indexed owner, address nftContract, uint256 tokenId, uint256 totalShares, uint256 pricePerShare);
    event SharesBought(uint256 indexed fid, address indexed buyer, uint256 shares, uint256 paid);
    event DustRefunded(uint256 indexed fid, address indexed buyer, uint256 refunded);
    event ProceedsClaimed(uint256 indexed fid, address indexed owner, uint256 amount);

    // FIX: msg.sender plane — the NFT holder creates their own fraction. The NFT
    // is escrowed into the contract via owner-approved transferFrom.
    function createFraction(address nftContract, uint256 tokenId, uint256 totalShares, uint256 pricePerShare)
        external nonReentrant returns (uint256) {
        require(totalShares > 0, "Zero shares");
        require(pricePerShare > 0, "Zero price");
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        Fraction storage f = fractions.push();
        f.nftContract = nftContract;
        f.tokenId = tokenId;
        f.owner = msg.sender;
        f.totalShares = totalShares;
        f.sharesSold = 0;
        f.pricePerShare = pricePerShare;
        f.active = true;
        f.claimed = false;
        uint256 fid = fractions.length - 1;
        fractionCount = fid + 1;
        ownerFractions[msg.sender].push(fid);
        emit FractionCreated(fid, msg.sender, nftContract, tokenId, totalShares, pricePerShare);
        return fid;
    }

    function buyShares(uint256 fid) external payable nonReentrant {
        Fraction storage f = fractions[fid];
        require(f.active, "Fraction inactive");
        require(f.sharesSold < f.totalShares, "All shares sold");
        uint256 bought = msg.value / f.pricePerShare;
        require(bought > 0, "Too little paid");
        require(f.sharesSold + bought <= f.totalShares, "Exceeds total shares");
        f.sharesSold += bought;
        shares[fid][msg.sender] += bought;
        emit SharesBought(fid, msg.sender, bought, msg.value);
    }

    function getFraction(uint256 fid) external view returns (address nftContract, uint256 tokenId, address owner, uint256 totalShares, uint256 sharesSold, uint256 pricePerShare, bool active) {
        Fraction storage f = fractions[fid];
        return (f.nftContract, f.tokenId, f.owner, f.totalShares, f.sharesSold, f.pricePerShare, f.active);
    }
    function getShares(uint256 fid, address user) external view returns (uint256) { return shares[fid][user]; }
}
