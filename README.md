# DAO Governance System

> A full-stack on-chain DAO with governance token, proposal lifecycle, voting, and treasury — built from scratch with Foundry.

[![Solidity](https://img.shields.io/badge/Solidity-0.8.x-blue)](https://soliditylang.org)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-red)](https://book.getfoundry.sh)
[![Tests](https://img.shields.io/badge/Tests-27%2F27%20passing-brightgreen)](#tests)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-v5-blueviolet)](https://openzeppelin.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🎯 What it does

A complete on-chain governance system where token holders can:

- **Create proposals** to spend treasury funds, parameterize the DAO, or call arbitrary targets
- **Vote** for / against proposals during the voting period
- **Execute** proposals that passed the quorum and majority threshold
- **Cancel** proposals (proposer or owner)
- **Manage a treasury** that holds ERC-20 tokens and ETH, with spending gated by successful proposals
- **Delegate** voting power through an ERC-20Votes-compatible governance token

Three contracts work together: the governance token, the DAO logic, and the treasury.

---

## 🏗 Architecture

```
┌──────────────────────┐
│  DAOGovernanceToken  │  ERC-20 + Votes
│  (ERC20Votes)        │  - mint (owner)
│                      │  - delegate / delegateBySig
└──────────┬───────────┘
           │ holds voting weight
           ▼
┌──────────────────────┐         ┌──────────────────────┐
│        DAO           │────────▶│     DAOTreasury      │
│                      │ spends  │                      │
│  - createProposal    │         │  - receive ERC20/ETH │
│  - vote              │         │  - spendFunds (only  │
│  - executeProposal   │         │    via DAO.execute)  │
│  - cancelProposal    │         │                      │
│  - updateConfig      │         │                      │
└──────────────────────┘         └──────────────────────┘
```

---

## 📂 Project structure

```
src/
├── DAO.sol                   # 300 LOC — proposal lifecycle
├── DAOGovernanceToken.sol    # 113 LOC — voting weight (ERC20Votes)
└── DAOTreasury.sol           # 178 LOC — fund custody
test/
└── DAO.t.sol                 # 27 tests across the lifecycle
```

---

## 🔑 Key functions

**DAO.sol**
- `createProposal(target, value, description, recipient, amount, token)` — submit a new proposal
- `vote(proposalId, support)` — cast a vote (uses snapshot-based voting weight)
- `executeProposal(proposalId)` — execute if quorum + majority met
- `cancelProposal(proposalId)` — proposer or owner can cancel
- `updateConfiguration(proposalThreshold, votingPeriod, quorumVotes)` — owner param tuning
- `setTreasury(address)` — owner sets the treasury
- `proposalPassed(proposalId)` — view: passed predicate
- `getVoteInfo(proposalId, voter)` — view: vote receipt

**DAOGovernanceToken.sol**
- Standard `ERC20Votes` with mint (owner)
- `delegate` / `delegateBySig` for gasless delegation

**DAOTreasury.sol**
- `spendFunds(proposalId, recipient, amount, token)` — **only callable by DAO contract**
- ReentrancyGuard on external calls
- Tracks per-proposal spent status

---

## 🛡 Security considerations

- **Snapshot-based voting:** uses `ERC20Votes` so voting weight is captured at proposal creation, preventing flash-loan vote-buying
- **Quorum + majority:** proposals only execute if both conditions hold
- **ReentrancyGuard:** on `spendFunds` and other value-moving calls
- **Custody separation:** treasury can ONLY spend via a successful DAO proposal — owner has no direct spend path
- **Cancellation:** proposer can cancel their own proposal; owner can cancel any
- **Idempotency:** executed/cancelled proposals cannot be re-executed

> ⚠️ This is a **Master's project**, not production. Production DAO frameworks (OpenZeppelin Governor, Compound / Tally) include additional safeguards (timelock, executor separation, on-chain proposal actions, etc.) that this project abstracts away for clarity.

---

## 🧪 Tests (27 passing)

```bash
bash install.sh
forge build
forge test -vv
```

Coverage highlights:

- **Proposal creation** — success, invalid params
- **Voting** — for, against, double-vote revert, snapshot weight
- **Execution** — success path, revert on insufficient votes, revert on quorum not met
- **Cancellation** — by proposer, by owner, revert on already-executed
- **Treasury** — `spendFunds` via DAO, revert on direct call, ETH + ERC-20 handling
- **Configuration** — owner updates, event emission
- **Edge cases** — zero-quorum, voting period boundary

---

## 📚 Concepts demonstrated

- ERC-20 with voting snapshots (`ERC20Votes`)
- Proposal lifecycle: created → active → (passed | failed) → (executed | canceled)
- Quorum and majority thresholds
- Treasury-custody separation
- Owner vs DAO authority boundaries
- Foundry test patterns for governance systems

---

## 📜 License

MIT — see [LICENSE](LICENSE)

---

**Author:** Santiago López Castaño · [@santilpz28](https://github.com/santilpz28)
Built as part of the **Master in Blockchain Development** (2026) — Governance module, final project.
