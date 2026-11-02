# SHARD — NFT Fractionalization

> SHARD splits one token into thousands of fungible shares that anyone can hold, trade or later re-combine. A board-lot custody contract safeguards the underlying collectible while shares circulate.

## What it does

SHARD splits one token into thousands of fungible shares that anyone can hold, trade or later re-combine. A board-lot custody contract safeguards the underlying collectible while shares circulate. The entire lifecycle lives in one contract, every button in the UI calls a real function on it — there is no mock backend.

## Contract

| | |
|---|---|
| File | `contracts/NFTFractionalization.sol` |
| Contract name | `NFTFractionalization` (inherits `ReentrancyGuard, Ownable`) |
| Solidity | `^0.8.20` |
| State functions | 7 (of which 1 payable) |
| Deployed (mainnet 677) | not yet deployed — placeholder `0x000…000` |

### Function surface

| Function | Type | Returns |
|---|---|---|
| `owner` | view | address |
| `transferFrom` | write | result / revert |
| `ownerOf` | view | address |
| `createFraction` | write | uint256 |
| `buyShares` | payable | tx receipt |
| `getFraction` | view | address nftContract, uint256 tokenId, address owner, uint256 totalShares, uint256 sharesSold, uint256 pricePerShare, bool active |
| `getShares` | view | uint256 |

### Events

| Event | Signature |
|---|---|
| `OwnershipTransferred` | (address indexed previousOwner, address indexed newOwner) |
| `FractionCreated` | (uint256 indexed fid, address indexed owner, address nftContract, uint256 tokenId, uint256 totalShares, uint256 pricePerShare) |
| `SharesBought` | (uint256 indexed fid, address indexed buyer, uint256 shares, uint256 paid) |
| `DustRefunded` | (uint256 indexed fid, address indexed buyer, uint256 refunded) |
| `ProceedsClaimed` | (uint256 indexed fid, address indexed owner, uint256 amount) |

## Network

| | |
|---|---|
| Chain | BOT Chain Mainnet (chainId `677`) |
| RPC | `https://rpc.botchain.ai` |
| Explorer | `https://scan.botchain.ai` |
| Native currency | BOT (18 decimals) |
| Testnet | BOT Chain Testnet (chainId `968`) - `https://rpc.bohr.life` |

## Frontend

- **Wallet connection** - [Reown/AppKit](https://reown.com) (Web3Modal v2, inline modal, `subscribeAccount` / `subscribeNetwork`)
- **Web3 library** - ethers.js v6 (`BrowserProvider`, `Contract`, `parseEther`)
- **Animation** - GSAP 3 + ScrollTrigger (`expo.out` entrances, `prefers-reduced-motion` fallback renders content instantly)
- **Zero build step** - single `index.html`, CDN imports via ESM import map; no bundler, no framework runtime
- **Accessibility** - auto-generated `aria-label`s on all binary and form controls, focus-visible styles, button busy states

## Run it locally

```bash
git clone https://github.com/Henoch4/nft-fractionalization.git
cd nft-fractionalization
# open the frontend directly (no build step)
start frontend/index.html   # Windows
# or serve it if your browser blocks file:// modules:
npx serve frontend
```

> **Note** — contract addresses: the UI reads its deploy target from the `CA` constant at the top of the inline script. Until the contract is deployed to mainnet 677, the demo runs against the deterministic sample data built into the page; after deployment, set `CA['677']` to the real address and every button goes live.