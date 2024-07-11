# HTLC

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
