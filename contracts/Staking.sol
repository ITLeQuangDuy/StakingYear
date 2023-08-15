pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Staking is Ownable {
    //struct UserInfo{}

    struct PoolInfo {
        address tokenAddress;
        uint256 lockDuration;
        uint256 rewardDuration;
        uint256 minStakeAmount;
        uint256 maxStakeAmount;
        uint256 maxPoolAmount;
        uint256 percent;
    }

    uint256 public lockDuration = 12 * 30 days;
    uint256 public totalPools;

    mapping(address => uint256) public stakeAmount;

    mapping(address => uint256) public stakeTime;

    mapping(address => uint256) public rewardAmount;

    mapping(address => uint256) public rewardAmount1;

    mapping(uint256 => PoolInfo) public pools;

    mapping(address => uint256) public lastTimeUpdateReward;
    mapping(address => mapping(uint256 => uint256)) public userStakes;
    mapping(address => mapping(uint256 => uint256)) public lastStakeTime;
    mapping(address => mapping(uint256 => uint256)) public unstakeTime;
    mapping(address => mapping(uint256 => uint256)) public lastRewardClaimTime;

    event Stake(address stakerAddress, uint256 amount, uint256 stakeTime); // stake

    constructor(address _addressUSDT, address _addressEXM) {
        addPool(
            _addressUSDT,
            31556926,
            259200,
            100 ether,
            10000 ether,
            1000000 ether,
            65
        );
        addPool(
            _addressEXM,
            47335374,
            604800,
            500 ether,
            50000 ether,
            5000000 ether,
            75
        );
    }

    function addPool(
        address _tokenAddress,
        uint256 _lockDuration,
        uint256 _rewardDuration,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _maxPoolAmount,
        uint256 _percent
    ) public {
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
    ) public {
        require(poolId <= totalPools, "Invalid pool ID");
        PoolInfo storage pool = pools[poolId];
        require(pool.tokenAddress != address(0), "Invalid Pool");

        pool.tokenAddress = _tokenAddress;
        pool.lockDuration = _lockDuration;
        pool.minStakeAmount = _minStakeAmount;
        pool.maxStakeAmount = _maxStakeAmount;
        pool.maxPoolAmount = _maxPoolAmount;
        pool.percent = _percent;
    }

    function stake(uint256 poolId, uint256 amount) external {
        require(poolId <= totalPools, "Invalid pool ID");
        PoolInfo storage pool = pools[poolId];
        require(pool.tokenAddress != address(0), "Invalid pool");
        require(
            amount >= pool.minStakeAmount && amount <= pool.maxStakeAmount,
            "Invalid amount"
        );

        IERC20(pool.tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        userStakes[msg.sender][poolId] += amount;
        lastStakeTime[msg.sender][poolId] = block.timestamp;
    }

    function unstake(uint256 poolId) external {
        require(poolId <= totalPools, "Invalid pool ID");
        PoolInfo storage pool = pools[poolId];
        require(pool.tokenAddress != address(0), "Invalid pool");
        uint256 a = userStakes[msg.sender][poolId];
        require(amount > 0, "No stake to withdraw");

        require(
            block.timestamp >=
                lastStakeTime[msg.sender][poolId] + pool.lockDuration,
            "Stake is still locked"
        );
        calculateReward(poolId);
        userStakes[msg.sender][poolId] = 0;
        IERC20(pool.tokenAddress).transfer(msg.sender, amount);
        unstakeTime[msg.sender][poolId] = block.timestamp;
    }

    function calculateReward(uint256 poolId) public view returns (uint256) {
        PoolInfo storage pool = pools[poolId];
        uint256 duration = unstakeTime[msg.sender][poolId] - lastStakeTime[msg.sender][poolId];
        //console.log(duration, pool.percent, userStakes[msg.sender][poolId]);
        uint256 reward = (duration * pool.percent * userStakes[msg.sender][poolId]) / (1000 * 31556926);
        return reward;
    }
}
