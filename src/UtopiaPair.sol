//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UtopiaCoin} from "./UtopiaErc20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IUtopiaFactory} from "./interface/IUtopiaFactory.sol";
import {IUtopiaPair} from "./interface/IUtopiaPair.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UtopiaPair is IUtopiaPair, IERC20, UtopiaCoin, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address immutable token0;
    address immutable token1;
    address factory;
    uint112 reserve0;
    uint112 reserve1;
    uint32 blockTimestampLast;
    uint256 public price0cumulative;
    uint256 public price1cumulative;
    uint256 public kLast;
    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

    error NotTokenAllowed();
    error NeedMoreThanZero();
    error NotEnoughtLiquidity(uint112 reserve0, uint112 reserve1);
    error NotEnoughtSharesMinted();

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

    constructor(address _factory, address _token0, address _token1) {
        factory = _factory;
        token0 = _token0;
        token1 = _token1;
    }

    modifier moreThanzero(uint256 amount) {
        if (amount <= 0) {
            revert NeedMoreThanZero();
        }
        _;
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUtopiaFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast;
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = _sqrt(uint256(_reserve0) * _reserve1);
                uint256 rootKLast = _sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * (rootK - rootKLast);
                    uint256 denominator = (rootK * 5) + (rootKLast);

                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external nonReentrant returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1) = getReserve();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = _sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(1), MINIMUM_LIQUIDITY);
        } else {
            liquidity = _min((amount0 * _reserve0) / _totalSupply, (amount1 * _reserve1) / _totalSupply);
        }
        if (liquidity <= 0) {
            revert NotEnoughtSharesMinted();
        }
        _mint(to, liquidity);
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) {
            kLast = uint256(_reserve0) * _reserve1;
        }
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1) = getReserve();
        address _token0 = token0;
        address _token1 = token1;
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf(address(this));
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply();
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;
        if (amount0 <= 0 || amount1 <= 0) revert NeedMoreThanZero();
        _burn(address(this), liquidity);
        IERC20(_token0).transfer(to, amount0);
        IERC20(_token1).transfer(to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(_reserve0) * uint256(_reserve1);
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to)
        external
        nonReentrant
        returns (uint256 amount0In, uint256 amount1In)
    {
        if (amount0Out <= 0 && amount1Out <= 0) {
            revert NeedMoreThanZero();
        }
        (uint112 _reserve0, uint112 _reserve1) = getReserve();

        if (amount0Out >= _reserve0 || amount1Out >= _reserve1) {
            revert NotEnoughtLiquidity(_reserve0, _reserve1);
        }
        uint256 balance0;
        uint256 balance1;
        address _token0 = token0;
        address _token1 = token1;
        //This scope is too avoid a stack error because stack only have place for 1024 32 bytes words.
        {
            if (_token0 == to || _token1 == to) {
                revert();
            }
            if (amount0Out > 0) IERC20(_token0).safeTransferFrom(address(this), to, amount0Out);
            if (amount1Out > 0) IERC20(_token1).safeTransferFrom(address(this), to, amount1Out);
            //Real balances can't be tracked so we need to check it in every swap to get "the real reserves".
            // because someone can transfer tokens with the ERC20 contract.
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        //After that we compute the Amount in.
        unchecked {
            amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
            amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        }
        {
            if (amount0In <= 0 && amount1In <= 0) revert();
            uint256 balance0Adjusted = (balance0 * 1000) - amount0In * 3;
            uint256 balance1Adjusted = (balance1 * 1000) - amount1In * 3;
            if (balance0Adjusted * balance1Adjusted != uint256(_reserve0) * _reserve1 * 1000 ^ 2) {
                revert();
            }
        }
        _update(balance0, balance1, _reserve0, _reserve1);

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
    // I prefered to add this function even if it doesn't exist in the uniswap implementation.

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    // I prefered to add this function even if it doesn't exist in the uniswap implementation.

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
        uint32 _blockTimestamp = uint32(block.timestamp % 2 ** 32);
        unchecked {
            uint32 interval = _blockTimestamp - blockTimestampLast;

            if (interval > 0 && _reserve0 != 0 && _reserve1 != 0) {
                price0cumulative += ((uint224(_reserve0) * 2 ** 112) / uint224(_reserve1)) * interval;
                price1cumulative += ((uint224(_reserve1) * 2 ** 112) / uint224(_reserve0)) * interval;
            }
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = uint32(_blockTimestamp);
    }

    function getReserve() public view returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function getK() public view returns (uint256 k) {
        return k = kLast;
    }

    function getPriceCumulative() public view returns (uint256 _price0cumulative, uint256 _price1cumulative) {
        _price0cumulative = price0cumulative;
        _price1cumulative = price1cumulative;
    }
}
