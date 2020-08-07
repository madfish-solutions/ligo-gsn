[Gas Station Network](https://docs.opengsn.org/learn/index.html) implementation on Tezos.
[FA1.2](https://gitlab.com/tzip/tzip/-/blob/master/proposals/tzip-7/tzip-7.md) is used as a usecase.

## Prerequirements

- Install [Ligo](https://ligolang.org/docs/intro/installation).
- Run local node on `http://127.0.0.1:8732` or set `$npm_package_config_network` in `package.json`
- Put unencrypted keys to `fixtures/key` and `fixtures/key1`; they will be used for contracts deployment and call.
- Install dependencies:

```
npm i
```

## Uaage

Build contracts:

```
npm run build
```

Deploy contracts:

```
npm run deploy
```

Test:

```
npm test
```

## Quuicl look on Carthagenet

```
Gsn deployed at: KT1G6n5DXEWMwwWmVyPs1cXbrwpDVQjTSaUu
Token deployed at: KT19hN68bxGvTAvr3wKZuVKBsZ2hFCP1nuq2
```
