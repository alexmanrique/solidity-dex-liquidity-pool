# solidity-liquidity-pool

SwapApp is a smart contract that facilitates token swapping and liquidity provision using Uniswap V2 Router. The contract allows performing swaps between tokens (especially USDT and DAI) and adding liquidity to Uniswap V2 pools.

## Features

- **Token Swapping**: Swap tokens using Uniswap V2 Router with slippage protection
- **Add Liquidity**: Automatically adds liquidity to a USDT/DAI pool, performing a swap of half the tokens before adding liquidity
- **Remove Liquidity**: Remove liquidity from a USDT/DAI pool, returning both tokens to the user
- **Fee System**: The contract owner collects a fee (default 1%) on every token swap, calculated from the output amount
- **Owner Controls**: The contract owner can adjust the fee percentage (up to 10% maximum)
- **Security**: Uses OpenZeppelin's SafeERC20 for secure token transfers and Ownable for access control
- **Events**: Emits events to track swaps, liquidity additions, and fee collections

## Contract

### SwapApp.sol

The main contract that implements the following functions:

- `swapTokens()`: Swaps exact tokens for other tokens using Uniswap V2 Router. Automatically deducts a fee from the output amount and transfers it to the contract owner.
- `addLiquidity()`: Adds liquidity to a USDT/DAI pool, automatically swapping half of the tokens. The internal swap also incurs the fee.
- `removeLiquidity()`: Removes liquidity from a USDT/DAI pool, returning both USDT and DAI tokens to the user
- `setFeeBasisPoints()`: Allows the contract owner to change the fee percentage (only callable by owner, maximum 10%)

### Constructor Parameters

- `V2Router02_`: Address of the Uniswap V2 Router02 contract
- `USDT_`: Address of the USDT token
- `DAI_`: Address of the DAI token
- `UniswapV2Factory_`: Address of the Uniswap V2 Factory contract
- `owner_`: Address of the contract owner who will receive swap fees

## Fee System

The contract implements a fee mechanism where the owner collects a percentage of each token swap:

- **Default Fee**: 1% (100 basis points) of the output amount
- **Fee Calculation**: The fee is calculated from the total output amount after the swap completes
- **Fee Collection**: The fee is automatically transferred to the contract owner's address
- **Fee Adjustment**: The owner can change the fee using `setFeeBasisPoints()`, with a maximum limit of 10% (1000 basis points)
- **Fee Application**: Fees are applied to all swaps, including internal swaps performed during `addLiquidity()`

### How Fees Work

1. When a user calls `swapTokens()`, the contract:

   - Receives tokens from the user
   - Performs the swap via Uniswap V2 Router (receiving tokens to the contract)
   - Calculates the fee: `feeAmount = (totalAmountOut * feeBasisPoints) / 10000`
   - Transfers the fee to the owner
   - Transfers the remaining amount to the user

2. The fee is deducted from the output tokens, not the input tokens
3. The `FeeCollected` event is emitted whenever a fee is collected

## Testing

Tests are configured to run on Arbitrum Mainnet using fork testing:

```shell
$ forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc
```

### Included Tests

- `testHasBeenDeployedCorrectly()`: Verifies that the contract has been deployed correctly
- `testSwapTokensCorrectly()`: Verifies that token swapping works correctly and that fees are collected by the owner
- `testAddLiquidityCorrectly()`: Verifies that liquidity addition works correctly and that fees are collected on internal swaps
- `testRemoveLiquidityCorrectly()`: Verifies that liquidity removal works correctly
- `testSetFeeBasisPoints()`: Verifies that the owner can change the fee and that the maximum fee limit is enforced
- `testSetFeeBasisPointsOnlyOwner()`: Verifies that only the owner can change the fee

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

For fork testing (Arbitrum):

```shell
$ forge test -vvvv --fork-url https://arb1.arbitrum.io/rpc
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Dependencies

- OpenZeppelin Contracts (SafeERC20, IERC20, Ownable)
- Forge Std (for testing)

## License

MIT
