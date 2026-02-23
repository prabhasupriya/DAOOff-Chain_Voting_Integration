# Robust DAO Governance System with Off-Chain Integration
## Project Overview
This project implements a modular, professional-grade Decentralized Autonomous Organization (DAO) governance system. Built with Solidity and OpenZeppelin, it features a token-weighted voting mechanism, a secure Timelock for execution, and an architectural bridge for off-chain voting attestation.
##  Architecture
The system follows a hub-and-spoke model where the Timelock acts as the central authority and owner of the assets. We utilize the UUPS (Universal Upgradeable Proxy Standard) for the Governor to allow for future logic upgrades without losing the DAO's history or address.

graph TD
    User((User)) -->|Delegates| Token[GOVToken]
    Token -->|Voting Power| Governor[DAOGovernor]
    User -->|Proposes| Governor
    Governor -->|Success| Timelock[DAOTimelock]
    Timelock -->|Delay Period| Execution[Execution]
    Execution -->|Calls| Treasury[Treasury Contract]
### Deployed Addresses (Local Anvil Node)
Contract Component,Address
GOVToken (Voting Power),0x5FbDB2315678afecb367f032d93F642f64180aa3
DAOTimelock (Execution Controller),0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Governor Proxy (The Brain),0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
Treasury (Asset Storage),0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
##  Design Decisions & Security
### 1. Hybrid Voting Model 
* Implemented a custom submitOffchainVoteResult function in DAOGovernor.sol.
* Allows the DAO to accept "attestations" of off-chain results (e.g., from Snapshot).
* Enables a hybrid approach: voting happens off-chain to save gas, while execution remains trustless on-chain.
### 2. Security Mechanisms
* Flash Loan Protection: Uses ERC20Votes with block-number checkpoints to ensure voting power is calculated at the moment of proposal creation.
* Execution Buffer: A mandatory 1-hour delay in DAOTimelock ensures a cooling-off period before funds are moved.
* Access Control: The Treasury is owned exclusively by the Timelock.
### ### 2. Gas Optimization
* **Calldata vs Memory:** Used `calldata` for all external function arrays to reduce gas costs during proposal submission.
* **Storage Packing:** State variables are ordered to minimize storage slot usage.
##  Setup & Testing Instructions
### Step 1: Build the Environment
Build the Docker container to ensure all dependencies are correctly installed.
```bash
docker-compose build --no-cache
docker-compose up -d
docker-compose exec app forge install openzeppelin/openzeppelin-contracts-upgradeable --no-git
```
### Step 2: Run Comprehensive Tests
Execute all unit and integration tests to verify the governance logic.
```bash
docker-compose exec app forge test -vv
docker-compose exec app forge test -vv --gas-report
```
### Step 3: Local Deployment
Start a local node:
```bash
docker-compose exec app anvil
```
Deploy via Script:
(Open a new terminal to run this while anvil is active)
```bash
docker-compose exec app forge script script/DeployDAO.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key <LOCAL_ANVIL_KEY>
```
##  Evidence of Functionality
### Automated Test Results
```bash
Ran 3 test suites: 5 tests passed, 0 failed, 0 skipped
[PASS] testInitialSupply()
[PASS] testVotingPowerAndDelegation()
[PASS] testGovernorSettings()
[PASS] testQuorumRequirement()
[PASS] testGovernanceExecutionFlow()
```

### Live Blockchain Verification
To confirm the UUPS Proxy is active and the Governor is initialized,I performed a name check:

Command: cast call 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 "name()(string)"

Response: "MyDAO"

##  Video Demo
Technical Walkthrough: A comprehensive video demonstration of the DAO Governance system, covering contract deployment, proposal creation, and execution flows.
**[Click here to watch the Project Video](https://youtu.be/CdmVDR7wjNM)**