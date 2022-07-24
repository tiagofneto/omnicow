// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "nxtp/interfaces/IConnextHandler.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "v2-periphery/interfaces/IUniswapV2Router02.sol";

/*
Contracts for:
    Polygon (137)       Sushi
    Gnosis (100)        Sushi
    Cronos (25)         VVS
    Celo (42220)        Sushi
    Neon (245022934)    Raydium
*/

contract Omnicow {
    IUniswapV2Router02 public uniswapV2Router;
    IERC20 public USDC;
    IERC20 public WETH;

    // IConnextHandler public immutable connext;

    uint256 public ETHvalue;

        // USDC
            // Rinkeby: 0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b
            // Kovan:   0xb7a4F3E9097C08dA09517b5aB877F7a917224ede
            // Polygon: 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174
            // Gnosis:  0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83
            // Celo:    

        // WETH
            // Rinkeby: 0xc778417E063141139Fce010982780140Aa0cD5Ab
            // Kovan:   0xd0A1E359811322d97991E03f863a0C30C2cF029C
            // Polygon: 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619
            // Gnosis:  
            // Celo:    

        // SushiSwap Router
            // Rinkeby: 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
            // Kovan:   0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
            // Polygon: 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
            // Gnosis:  0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
            // Celo:    0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F

        // Connext
            // Rinkeby: 
            // Kovan: 

    constructor(address _USDC, address _WETH, address _router) {
        USDC = IERC20(_USDC);
        WETH = IERC20(_WETH);
        uniswapV2Router = IUniswapV2Router02(_router);
    }

    function fireBundle(
        address[] calldata user, // to pull from
        address[] calldata token, // if token = USDC, user is buying, if token = WETH, user is selling
        uint256[] calldata amount, // amount of token to pull
        uint256 tradingAmount, // USD value amount of ETH to buy or sell on DEX
        bool buyingOrSellingETH // true = buying ETH, false = selling ETH
    ) public {

        uint256 totalUSDC;
        uint256 totalWETH;

        for (uint256 i = 0; i < user.length; i++) {

            // If user is selling
            if (token[i] == address(WETH)) {

                // Transfers WETH from user to the contract
                uint256 wethAmount = amount[i] / ETHvalue;
                IERC20(token[i]).transferFrom(user[i], address(this), wethAmount);

                totalWETH += wethAmount;

            // If user is buying
            } else {
                
                // Transfers USDC from user to the contract
                IERC20(token[i]).transferFrom(user[i], address(this), amount[i]);

                totalUSDC += amount[i];
            }
        }   

        // if need to buy ETH
        if (buyingOrSellingETH = true) {
            //Sushi buy ETH
            swapExactTokensForTokens(address(USDC), address(WETH), tradingAmount);

        } else {
            //if need to sell ETH

            //Sushi sell ETH
            swapExactTokensForTokens(address(WETH), address(USDC), uint256(tradingAmount / ETHvalue));
        }

        // Transfers funds from contract to user
        for (uint256 i = 0; i < user.length; i++) {
            
            address receiveToken;
            uint256 fundsForUser; 

            // if user was selling WETH, they receive USDC
            if (token[i] == address(WETH)) {
                receiveToken = address(USDC);
                
                uint256 percentOfTokens = (amount[i] / totalWETH) * 100;
                fundsForUser = (totalUSDC / 100) * percentOfTokens;

            } else {
                // if user was buying WETH, they receive WETH
                receiveToken = address(WETH);

                uint256 percentOfTokens = (amount[i] / totalUSDC) * 100;
                fundsForUser = (totalUSDC / 100) * percentOfTokens;
            }
            
            IERC20(receiveToken).transferFrom(address(this), user[i], fundsForUser);
        }   
    }

    function swapExactTokensForTokens(
        address tokenSell,
        address tokenBuy,
        uint256 tokenAmount
        ) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenSell;
        path[1] = tokenBuy;

        IERC20(tokenSell).approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    // function bridge(
    //     address to, // the destination address (e.g. a wallet)
    //     address asset, // address of token on source domain
    //     uint32 originDomain, // e.g. from Rinkeby (1111)
    //     uint32 destinationDomain, // to Goerli (3331)
    //     uint256 amount // amount to transfer
    // ) public {
    //     ERC20 token = ERC20(asset);
    //     require(token.allowance(msg.sender, address(this)) >= amount, "User must approve amount");

    //     token.transferFrom(msg.sender, address(this), amount);
    //     token.approve(address(connext), amount);
    
    //     IConnextHandler.CallParams memory callParams = IConnextHandler.CallParams({
    //     to: to,
    //     callData: "",
    //     originDomain: originDomain,
    //     destinationDomain: destinationDomain,
    //     agent: to,
    //     recovery: to,
    //     forceSlow: false,
    //     receiveLocal: false,
    //     callback: address(0),
    //     callbackFee: 0,
    //     relayerFee: 0,
    //     slippageTol: 9995
    //     });

    //     IConnextHandler.XCallArgs memory xcallArgs = IConnextHandler.XCallArgs({
    //     params: callParams,
    //     transactingAssetId: asset,
    //     amount: amount
    //     });
    // }

}
