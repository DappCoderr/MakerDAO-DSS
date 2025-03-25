## Stablecoin using CDPs (Collateralized Debt Positions)

🚨 Code is not audited. Do not use in production

This project is a decentralized stablecoin designed to maintain a stable value pegged to the US Dollar (USD). It achieves this stability through CDPs and automated mechanisms to ensure the stablecoin remains over-collateralized and secure.

How It Works 🔄
1. Users lock up crypto assets (e.g., ETH) as collateral in a CDP.
2. Mint stablecoins against the collateral, up to a percentage of its value.
3. Liquidation Threshold is set. If your borrowed amount exceeds the threshold of your collateral’s value, the CDP is liquidated.
4. Real-Time price feeds track collateral values and the stablecoin’s USD peg using Chainlink.
