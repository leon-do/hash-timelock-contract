# HTLC

For EVM to Non-EVM cross chain swaps


[![](https://github.com/leon-do/hash-timelock-contract/assets/19412160/698f151d-e11e-452e-877f-24b760dcd4c7)]([https://codecademy.com](https://www.youtube.com/watch?v=12Y0qTUlRKU))

LND: https://www.youtube.com/watch?v=12Y0qTUlRKU

Stellar: https://leondo.medium.com/stellar-hash-timelock-contract-htlc-9cdc998999c5

## Install

```shell
forge install --no-commit --shallow OpenZeppelin/openzeppelin-contracts
```

## Documentation

https://book.getfoundry.sh/

## Usage

### Format

```shell
forge fmt
```

### Build

```shell
forge build
```

### Test

```shell
forge test --watch --run-all
```

### Deploy

```shell
source .env

forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $RPC_URL \
    --broadcast --verify -vvvv \
    --legacy
```
