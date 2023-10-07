## Constant Product AMM

This is a constant rpoduct AMM which is similar to Uniswap V2

## What is a constant product AMM ?

a constant product AMM mean that X\*Y=K with :
X the amount of token X
Y the amount of token Y
K remain the same with a swap but change during adding or removing liquidities.

## How to calculate the amount out of a swap ?

previously:

XY = K
now :

(X+dx)(Y-dy)=K
dx the amount of x in
dy the amount of y out
so:
(x+dx)(Y-dy)=XY
XY-Xdy+Ydx-dxdy=XY
-dxdy-Xdy=-Ydx
dy(X+dx)=Ydx
dy=ydx/(X+dx)

## How many token to add ?

The only constrain is tha the price much remain the same:

P= X/Y
X is still the amount of token X
Y is still the amount of token Y
(x+dx)/(Y+dy)=X/Y
(x+dx)Y = X(Y+dy)
YX+ Ydx= XY+ Xdy
Ydx= Xdy
dx/dy= X/Y
It's totally logical it means that the increase of liquidity must be propotional

## How do we measure liquidity ?

liquidity = sqrt(X\*Y)

## How many shares to mint ?

the increase of shares will be proportional with increase of liquidity
We have:
T the total shares
S the shares minted
L1 the liquidity after
L0 the liquidity before

L1/L0 = (T+S)/T
TL1/L0 = (T+S)
(TL1-TL0)/L0 = S

S = T(L1-L0)/L0
S = T(sqrt((X+dx)(Y+dy))-sqrt(XY))/sqrt(XY)

after some algebra

S=(dx/X)T=(dy/Y)T
