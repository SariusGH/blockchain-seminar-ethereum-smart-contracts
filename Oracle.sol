// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Oracle {
    address public owner;
    bool public tournamentCompleted = false;
    address public firstPlace;
    address public secondPlace;
    address public thirdPlace;


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    function saveResult(address _firstPlace, address _secondPlace, address _thirdPlace) external onlyOwner {
        require(!tournamentCompleted, "Tournament already completed");
        require(_firstPlace != address(0) && _secondPlace != address(0) && _thirdPlace != address(0), "Invalid address");
        firstPlace = _firstPlace;
        secondPlace = _secondPlace;
        thirdPlace = _thirdPlace;
        tournamentCompleted = true;
    }

    function isTournamentCompleted() external view returns (bool) {
        return tournamentCompleted;
    }

    function getWinners() external view returns (address, address, address) {
        return (firstPlace, secondPlace, thirdPlace);
    }
}
