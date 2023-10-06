# Utopia DEX

This is a Dex call Utopia it's very similar to UniswapV2 and it's factory system.

## What is a factory pattern ?

A factory patter is a pattern where a factory contract deploy another smart contract using create or create2.

Into the core contracts the Factory create using create2 a pair contract that allows you to swap, add liquidity and mint shares.
the pair contract also inherit from an ERC20 contract in order to allow liquidity providers to mint shares. This dex is a constant product AMM.

## What is a constant product AMM ?

A constant product AMM is a protoco to exchange tokens where the product of the reserves of the two tokkens X and Y equal a constant K.
X\*Y=K
This constant can change only if we add or remove liquidity but in a swap it doesn't change.



### Swap - How many dy for dx?
For a given amount dx of the token x the user will have an amount of token y dy to respect the constant K.
In order to swap the constant must remain the same.
(x+dx)(y-dy)=K
(x+dx)(y-dy)= XY
dy= ydx/x+dx




### Add liquidity - How many dx, dy to add?

To add liquidity the only constrain is the price the price should not change after adding liquidity.
The price in a pool is given by this formula :
P= X/Y
we deduct that: 
X/Y=dy/dx

#### Add liquidity - How many shares to mint?
s=Minted shares
T= Total shares
dx= the amount of token x added
dy= the amount of token y added
s=(dx/x)T= (dy/y)T


### Remove liquidity - How many tokens to withdraw?

dx= x*s/T
dy= Y*s/T
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



