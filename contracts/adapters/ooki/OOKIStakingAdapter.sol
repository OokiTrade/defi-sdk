// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

import {ERC20} from "../../ERC20.sol";
import {ProtocolAdapter} from "../ProtocolAdapter.sol";

/**
 * @dev StakingRewards contract interface.
 * Only the functions required for AragonStakingAdapter contract are added.
 * The StakingRewards contract is available here
 * github.com/Synthetixio/synthetix/blob/master/contracts/StakingRewards.sol.
 */
interface StakingRewards {
    function earned(address)
        external
        view
        returns (
            uint256 bzrxRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 bzrxRewardsVesting,
            uint256 stableCoinRewardsVesting
        );

    function balanceOfByAssets(address account)
        external
        view
        returns (
            uint256 bzrxBalance,
            uint256 iBZRXBalance,
            uint256 vBZRXBalance,
            uint256 lPTokenBalance
        );

    function balanceOfByAsset(address token, address account)
        external
        view
        returns (uint256 balance);
}

/**
 * @title Adapter for BZX protocol (staking).
 * This will return current staking + earnigns that can be immediately withdrawn.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Roman Iftodi <romeo8881@gmail.com>
 */
contract OOKIStakingAdapter is ProtocolAdapter {
    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant IOOKI = 0x05d5160cbc6714533ef44CEd6dd32112d56Ad7da;
    address internal constant VBZRX = 0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F;
    address internal constant OOKI = 0x0De05F6447ab4D22c8827449EE4bA2D5C288379B;
    address internal constant SLP = 0xEaaddE1E14C587a7Fb4Ba78eA78109BB32975f1e;
    address internal constant CURVE3CRV = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;

    address internal constant STAKING_CONTRACT = 0x16f179f5C344cc29672A58Ea327A26F64B941a63;

    /**
     * @return Amount of staked LP tokens for a given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account)
        external
        view
        override
        returns (uint256)
    {
        if (token == IOOKI || token == VBZRX || token == SLP) {
            return StakingRewards(STAKING_CONTRACT).balanceOfByAsset(token, account);
        } else if (token == OOKI) {
            (uint256 bzrxEarnings, , , ) = StakingRewards(STAKING_CONTRACT).earned(account);
            return StakingRewards(STAKING_CONTRACT).balanceOfByAsset(token, account) + bzrxEarnings;
        } else if (token == CURVE3CRV) {
            (, uint256 curve3crv, , ) = StakingRewards(STAKING_CONTRACT).earned(account);
            return curve3crv;
        } else {
            return 0;
        }
    }
}
