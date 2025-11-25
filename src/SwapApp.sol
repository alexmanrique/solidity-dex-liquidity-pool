// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IV2Router02} from "./interfaces/IV2Router02.sol";

contract SwapApp {
    using SafeERC20 for IERC20;
    address public V2Router02Address;
    address public USDT;
    address public DAI;
    event SwapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address tokenA, address tokenB, uint256 liquidity);

    constructor(address V2Router02_, address USDT_, address DAI_) {
        V2Router02Address = V2Router02_;
        USDT = USDT_;
        DAI = DAI_;
    }

    function swapTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        public
        returns (uint256 amountOut)
    {
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(V2Router02Address, amountIn);
        uint256[] memory amountOuts =
            IV2Router02(V2Router02Address).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
        emit SwapTokens(path[0], path[path.length - 1], amountIn, amountOuts[amountOuts.length - 1]);

        return amountOuts[amountOuts.length - 1];
    }

    function addLiquidity(
        uint256 amountIn_,
        uint256 amountOutMin_,
        address[] calldata path_,
        uint256 amountAMin_,
        uint256 amountBMin_,
        uint256 deadline_
    ) external {
        IERC20(USDT).safeTransferFrom(msg.sender, address(this), amountIn_ / 2);
        uint256 swapedAmount = swapTokens(amountIn_ / 2, amountOutMin_, path_, address(this), deadline_);

        IERC20(USDT).approve(V2Router02Address, amountIn_ / 2);
        IERC20(DAI).approve(V2Router02Address, swapedAmount);

        (,, uint256 liquidity) = IV2Router02(V2Router02Address)
            .addLiquidity(USDT, DAI, amountIn_ / 2, swapedAmount, amountAMin_, amountBMin_, msg.sender, deadline_);

        emit AddLiquidity(USDT, DAI, liquidity);
    }
}
