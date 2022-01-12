// SPDX-License-Identifier: MIT
///////////////////////////////////
// Date: 2021-12-22
// Author: Ujesh
///////////////////////////////////

pragma solidity >=0.6.2;
// Import IERC20, IUniswapV2Factory, IUniswapV2Pair, IUniswapV2Router01 and IUniswapV2Router02
// Im using the V2 contracts because they're more common (only uniswap on mainnet uses V3, all the other DEXes use V2). Ofc this has nothing to do with the fact that i have no idea how uniswapV3 contracts work ^^'. 
import './IPancakeRouter01.sol';
import './IPancakeRouter02.sol';
import './IERC20.sol';
import './IPancakeFactory.sol';
import './IPancakePair.sol';

contract MultiSwap {
    IPancakeRouter02 router;

    constructor() {
        router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    }

    function deposit(address token, uint256 inputAmount) external{
         IERC20(token).transferFrom(msg.sender, address(this), inputAmount);
    }

    function withdraw(address token, uint256 amount) external {
            IERC20(token).transfer(msg.sender, amount);
 
    }

    function getBalance(address token) public view returns(uint256){
            return IERC20(token).balanceOf(address(this));
    }

    function multiswap(address[] memory path) external {

        for(uint256 i=0; i < path.length - 1; i++) {
            address[] memory tempPath = new address[](2);
            tempPath[0] = path[i];
            tempPath[1] = path[i+1]; 
            uint256 amountIn = IERC20(tempPath[0]).balanceOf(address(this)); // This assumes the balance is 0 before a call is made, if its not the case the tokens that were here will be swapped as well (that can be fixed pretty easily) 
            uint256 expectedOutput = router.getAmountsOut(amountIn, tempPath)[1];
            uint256 minimumOutput = expectedOutput * (100 - 5)/100; // Defines the minimum acceptable amount using slippagePercentForEach
            require(IERC20(tempPath[0]).approve(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3), amountIn), 'approve failed.');
            router.swapExactTokensForTokens( 
                amountIn,
                minimumOutput,
                tempPath,
                address(this),
                (block.timestamp + 100)
            );
        }
    }
}