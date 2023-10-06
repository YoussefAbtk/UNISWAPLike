# Utopia DEX

This is a Dex call Utopia it's very similar to UniswapV2 and it's factory system.

## What is a factory pattern ?

A factory patter is a pattern where a factory contract deploy another smart contract using create or create2.

Into the core contracts the Factory create using create2 a pair contract that allows you to swap, add liquidity and mint shares.
the pair contract also inherit from an ERC20 contract in order to allow liquidity providers to mint shares. This dex is a constant product AMM.

## What is a constant product AMM ?

A constant product AMM means that the product of the reserves of the two tokkens X and Y equal a constant K.
X\*Y=K
This constant can change only if we add or remove liquidity but in a swap it doesn't change.



### Swap - How many dy for dx?



**Uniswap trading fee = 0.3%**



### Add liquidity - How many dx, dy to add?



#### Add liquidity - How many shares to mint?



Motivation:



What is L0 and L1



Simplify the equation:



**Conclusion**



### Remove liquidity - How many tokens to withdraw?

<div>
 <img src="images/Maths09bis.png" alt="Maths">
</div>

## Time Weighted Average Price

<div>
 <img src="images/Maths10.png" alt="Maths">
</div>

### How do we compute the Time Weighted Average Price from Tk to Tn?

<div>
 <img src="images/Maths11.png" alt="Maths">
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



