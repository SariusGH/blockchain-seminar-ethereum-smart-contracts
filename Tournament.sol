// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Oracle.sol";

contract Tournament {
    address public owner;
    Oracle public oracle;

    mapping(address => uint256) public balances;
    mapping(address => bool) public players;
    bool public rewardsCalculated;
    bool private locked;

    event PlayerAdded(address player);
    event BalanceAdded(uint256 amount);
    event PrizesCalculated();
    event BalanceWithdrawn(address player, uint256 amount);

    constructor(address _oracle) {
        owner = msg.sender;
        oracle = Oracle(_oracle);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyValidPlayer(address player) {
        require(players[player], "Player not valid");
        _;
    }

    function addPlayer(address player) external onlyOwner {
        require(!oracle.isTournamentCompleted(), "Tournament already completed");
        require(player != address(0), "Invalid address");
        if (!players[player]) {
            players[player] = true;
            emit PlayerAdded(player);
        }
    }

    function registerTournament() external {
        require(!oracle.isTournamentCompleted(), "Tournament already completed");
        require(!players[msg.sender], "Already registered");
        players[msg.sender] = true;
        emit PlayerAdded(msg.sender);
    }

    function addBalance() external payable {
        require(!oracle.isTournamentCompleted(), "Tournament already completed");
        emit BalanceAdded(msg.value);
    }

    function calculatePrizes() external onlyOwner noReentrant {
        require(oracle.isTournamentCompleted(), "Tournament not completed yet");
        require(!rewardsCalculated, "Rewards already calculated");

        (address firstPlace, address secondPlace, address thirdPlace) = oracle.getWinners();

        require(players[firstPlace] && players[secondPlace] && players[thirdPlace], "Winners must be valid players");

        uint256 totalBalance = address(this).balance;
        uint256 firstPrize = (totalBalance * 45) / 100;
        uint256 secondPrize = (totalBalance * 30) / 100;
        uint256 thirdPrize = (totalBalance * 22) / 100;

        balances[firstPlace] = firstPrize;
        balances[secondPlace] = secondPrize;
        balances[thirdPlace] = thirdPrize;

        rewardsCalculated = true;
        emit PrizesCalculated();
    }

    function withdrawBalance() external noReentrant onlyValidPlayer(msg.sender) {
        require(rewardsCalculated, "Rewards not calculated yet");
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance to withdraw");
        require(address(this).balance >= balance, "Not enough balance in contract");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
        emit BalanceWithdrawn(msg.sender, balance);
    }

    function getTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
