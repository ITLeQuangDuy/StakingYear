/*
    stake bằng token erc20(có 2 loại EXM và USDT)
    sử dụng struct [
        tokenAddress , đồng tiên stake của pool này là gì.
        thời gian khóa
        thời gian có thể nhận
        số tiền tối thiểu /  user: Ex: USDT : 100, EXM: 500.
        số tiền tối đa / user: Ex: 10000 USDT, EXM: 50000.
        số tiền đã mua
        số tiền tối đa của pool: USDT 1000000 EXM 5000000
    ]
    stake
        + khóa tiền stake: đối với USDT 12 tháng, đối với EXM 18 tháng.
        + tiền thưởng có thể nhận sau 3 ngày đối với EXM, USDT 7 ngày. (tính từ thời gian stake)
    unstake
    withdraw
        + 12 tháng có thể  rút
    calculateReward(lãi 6,5 tiền trong 12 tháng)
    withdrawReward

 */

/*

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract {
    struct PoolInfo {
        address tokenAddress;
        uint256 lockDuration;
        uint256 rewardDuration;
        uint256 minStakeAmount;
        uint256 maxStakeAmount;
        uint256 maxPoolAmount;
    }

    mapping(uint256 => PoolInfo) public pools;
    mapping(address => mapping(uint256 => uint256)) public userStakes;
    mapping(address => mapping(uint256 => uint256)) public lastStakeTime;
    mapping(address => mapping(uint256 => uint256)) public lastRewardClaimTime;

    uint256 public totalPools;
    
    event Staked(address indexed user, uint256 indexed poolId, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed poolId, uint256 amount);
    event RewardClaimed(address indexed user, uint256 indexed poolId, uint256 amount);

    constructor(address _addressUSDT, address _addressEXM) {
        addPool(address(_addressEXM), 12 * 30 days, 3 days, 100 * 10e18, 10000 * 10e18, 1000000 * 1e6);
        addPool(address(_addressEXM), 18 * 30 days, 7 days, 500 * 1e18, 50000 * 1e18, 5000000 * 1e18);
    }

    function addPool(address tokenAddress, uint256 lockDuration, uint256 rewardDuration, uint256 minStakeAmount, uint256 maxStakeAmount, uint256 maxPoolAmount) public {
        totalPools++;
        pools[totalPools] = PoolInfo({
            tokenAddress: tokenAddress,
            lockDuration: lockDuration,
            rewardDuration: rewardDuration,
            minStakeAmount: minStakeAmount,
            maxStakeAmount: maxStakeAmount,
            maxPoolAmount: maxPoolAmount
        });
    }

    function stake(uint256 poolId, uint256 amount) external {
        require(poolId <= totalPools, "Invalid pool ID");
        PoolInfo storage pool = pools[poolId];
        require(pool.tokenAddress != address(0), "Invalid pool");
        require(amount >= pool.minStakeAmount && amount <= pool.maxStakeAmount, "Invalid amount");

        IERC20(pool.tokenAddress).transferFrom(msg.sender, address(this), amount);
        userStakes[msg.sender][poolId] += amount;
        lastStakeTime[msg.sender][poolId] = block.timestamp;

        emit Staked(msg.sender, poolId, amount);
    }

    function unstake(uint256 poolId) external {
        require(poolId <= totalPools, "Invalid pool ID");
        PoolInfo storage pool = pools[poolId];
        require(pool.tokenAddress != address(0), "Invalid pool");
        uint256 amount = userStakes[msg.sender][poolId];
        require(amount > 0, "No stake to withdraw");

        require(block.timestamp >= lastStakeTime[msg.sender][poolId] + pool.lockDuration, "Stake is still locked");

        userStakes[msg.sender][poolId] = 0;
        IERC20(pool.tokenAddress).transfer(msg.sender, amount);

        emit Unstaked(msg.sender, poolId, amount);
    }

    function claimReward(uint256 poolId) external {
        require(poolId <= totalPools, "Invalid pool ID");
        PoolInfo storage pool = pools[poolId];
        require(pool.tokenAddress != address(0), "Invalid pool");
        require(userStakes[msg.sender][poolId] > 0, "No stake to claim reward");
        require(block.timestamp >= lastRewardClaimTime[msg.sender][poolId] + pool.rewardDuration, "Reward not yet available");

        uint256 rewardAmount = (userStakes[msg.sender][poolId] * pool.rewardDuration * getAPY(pool.tokenAddress)) / (365 days * 100);
        lastRewardClaimTime[msg.sender][poolId] = block.timestamp;

        IERC20(pool.tokenAddress).transfer(msg.sender, rewardAmount);
    }

    
}
/*
Yêu cầu: Contract staking: phần trăm trả thưởng theo năm.
        có 2 contract riêng mint: USDT vs EXM ( Example Token)
        Có một số chức năng cơ bản: stake, unstake, withdrawReward ( lưu ý : phải có event )
        Sau khi stake:  + số tiền user sẽ khóa : đối với USDT: 12 tháng, đối với EXM: 18 tháng.
                        + Tiền thưởng user có thể nhận: USDT: 3 ngày, đối với EXM: 7 ngày.
        User có quyền sử dụng tiền thưởng stake thêm vào.
        Mỗi lần stake thêm hay stake lại lần nữa thì các thông số phụ thuộc sẽ phải thay đổi theo ( Thời gian khóa, thời gian nhận thưởng)
        struct poolInfo[
            tokenAddress , đồng tiên stake của pool này là gì.
            thời gian khóa
            thời gian có thể nhận
            số tiền tối thiểu /  user: Ex: USDT : 100, EXM: 500.
            số tiền tối đa / user: Ex: 10000 USDT, EXM: 50000.
            số tiền đã mua:
            số tiền tối đa của pool: USDT 1000000 EXM 5000000
        ]
        mapping(uint256 => nameStruct) public pools;
        IndexPool = 0;

 */
