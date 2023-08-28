// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is Ownable {
    struct UserInfo {
        uint256 amountStaked;
        uint256 lastStakeTime;
        uint256 rewardEarned;
        uint256 lastRewardUpdateTime;
        uint256 lastRewardWithdrawTime;
    }

    struct PoolInfo {
        address tokenAddress;
        uint256 lockDuration;
        uint256 rewardDuration;
        uint256 minStakeAmount;
        uint256 maxStakeAmount;
        uint256 maxPoolAmount;
        uint256 percent;
    }

    event Stake(address StakeAddress, uint256 Amount, uint256 PoolId);
    event UnStake(address UnStakeAddress, uint256 Amount, uint256 PoolId);
    event WithdrawReward(address WithdrawReward, uint256 Reward, uint256 PoolId);

    uint256 public totalPools;

    mapping(uint256 => PoolInfo) public pools;
    mapping(address => mapping(uint256 => UserInfo)) public userStakes;
    mapping(uint256 => uint256) public amountMaxPool;
    //mapping(address => mapping(uint256 => uint256)) public lastRewardWithdrawTime;

    function addPool(
        address _tokenAddress,
        uint256 _lockDuration,
        uint256 _rewardDuration,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _maxPoolAmount,
        uint256 _percent
    ) public {
        require(_tokenAddress != address(0),"Invalid token address");
        totalPools++;

        pools[totalPools] = PoolInfo({
            tokenAddress: _tokenAddress,
            lockDuration: _lockDuration,
            rewardDuration: _rewardDuration,
            minStakeAmount: _minStakeAmount,
            maxStakeAmount: _maxStakeAmount,
            maxPoolAmount: _maxPoolAmount,
            percent: _percent
        });
    }

    function updatePool(
        uint256 poolId,
        address _tokenAddress,
        uint256 _lockDuration,
        uint256 _rewardDuration,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _maxPoolAmount,
        uint256 _percent
    ) public onlyOwner {
        require(poolId <= totalPools, "Invalid pool ID");
        require(_tokenAddress != address(0), "Invalid address");

        PoolInfo storage pool = pools[poolId];

        pool.tokenAddress = _tokenAddress;
        pool.lockDuration = _lockDuration;
        pool.rewardDuration = _rewardDuration;
        pool.minStakeAmount = _minStakeAmount;
        pool.maxStakeAmount = _maxStakeAmount;
        pool.maxPoolAmount = _maxPoolAmount;
        pool.percent = _percent;
    }

    function getRound(uint poolId) external view returns (
        address tokenAddress,
        uint256 lockDuration,
        uint256 rewardDuration,
        uint256 minStakeAmount,
        uint256 maxStakeAmount,
        uint256 maxPoolAmount,
        uint256 percent
    ){
        require(poolId > 0 && poolId <= totalPools, "Pool does not exist");
        PoolInfo memory pool = pools[poolId];
        
        return(
            pool.tokenAddress,
            pool.lockDuration,
            pool.rewardDuration,
            pool.minStakeAmount,
            pool.maxStakeAmount,
            pool.maxPoolAmount,
            pool.percent
        );
    }

    function stake(uint256 poolId, uint256 amount) external {
        address userAddress = msg.sender;
        require(poolId <= totalPools, "Invalid pool ID");

        PoolInfo storage pool = pools[poolId];
        UserInfo storage user = userStakes[userAddress][poolId];

        require(amount >= pool.minStakeAmount, "Amount is less than minimum stake amount");
        require(amount <= pool.maxStakeAmount, "Amount is greater than maximum stake amount");
        require(amount + amountMaxPool[poolId] <= pool.maxPoolAmount, "Exceeds maximum pool amount");
        
        updateReward(poolId, userAddress);
        
        user.amountStaked += amount;
        amountMaxPool[poolId] += amount;
        user.lastStakeTime = block.timestamp;

        IERC20(pool.tokenAddress).transferFrom(userAddress, address(this),amount);

        emit Stake(userAddress, poolId, amount);
    }

    function unStake(uint256 poolId) external {
        require(poolId <= totalPools, "Invalid pool ID");
        address userAddress = msg.sender;
        UserInfo storage user = userStakes[userAddress][poolId];
        updateReward(poolId, userAddress);
        
        require(block.timestamp >= user.lastStakeTime + pools[poolId].lockDuration, "Invalid time unstaking");
        
        uint256 amount = user.amountStaked + user.rewardEarned;
        
        user.rewardEarned = 0;
        user.amountStaked = 0;

        IERC20(pools[poolId].tokenAddress).transfer(userAddress, amount);

        emit UnStake(userAddress, amount, poolId);
    }

    function updateReward(uint256 poolId, address _address) internal {
        UserInfo storage user = userStakes[_address][poolId];
        uint256 reward = calculateReward(msg.sender, poolId);

        user.rewardEarned += reward;
        user.lastRewardUpdateTime = block.timestamp;
    }

    function calculateReward(address _address ,uint256 poolId) public view returns (uint256) {
        UserInfo storage user = userStakes[_address][poolId];
        
        uint256 duration = block.timestamp - user.lastRewardUpdateTime;
        return (duration * pools[poolId].percent * user.amountStaked) / (1000 * 31556926);
    }

    function claimReward(uint256 poolId) public {
        address userAddress = msg.sender;
        UserInfo storage user = userStakes[userAddress][poolId];

        updateReward(poolId, userAddress);
        require(user.amountStaked > 0, "No staked amount");
        require(user.rewardEarned > 0, "No reward available for withdrawal");
        uint256 reward = user.rewardEarned;

        if(user.lastRewardWithdrawTime == 0){
            require(block.timestamp >= user.lastStakeTime + pools[poolId].rewardDuration, "Not enough time to withdraw 1");
            user.rewardEarned = 0;
            IERC20(pools[poolId].tokenAddress).transfer(userAddress, reward);
            user.lastRewardWithdrawTime = block.timestamp;
        }else{
            require(block.timestamp >= user.lastRewardWithdrawTime + pools[poolId].rewardDuration, "Not enough time to withdraw 2");
            user.rewardEarned = 0;
            IERC20(pools[poolId].tokenAddress).transfer(userAddress, reward);
            user.lastRewardWithdrawTime = block.timestamp;
        }

        emit WithdrawReward(userAddress, reward, poolId);
    }

    function getTimePresent() public view returns (uint256){
        return block.timestamp;
    }
}
