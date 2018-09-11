pragma solidity ^0.4.24;

import "./ifum.sol";
import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract IFUMCrowdsale is Ownable, Pausable {

    using SafeERC20 for IFUM;

    enum Stage {
        Prepare,        // 0
        Presale,        // 1
        Crowdsale,      // 2
        Distribution,   // 3
        Finished        // 4
    }

    IFUM public token;

    address private _wallet;

    Stage public stage = Stage.Prepare;

    constructor(address wallet) public {
        setWallet(wallet);
    }

    /**
     * @dev Set the address of the wallet to transfer automatically when the contract receives ether.
     * @param wallet The address for receiving ether.
     */
    function setWallet(address wallet) public onlyOwner {
        require(wallet != address(0));
        address prev = _wallet;
        _wallet = wallet;
        emit SetWallet(prev, wallet);
    }

    /**
     * @dev Set the token contract. This function must be called at Prepare(0) stage.
     * @param newToken The address of IFUM token contract.
     */
    function setTokenContract(IFUM newToken) public onlyOwner {
        require(newToken != address(0));
        address prev = token;
        token = newToken;
        emit SetTokenContract(prev, newToken);
    }

    /**
     * @dev If the contact receives ether in Presale or Crowdsale stage, send ether to _wallet automatically.
     */
    function () external payable {
        require(msg.value != 0);
        require(stage == Stage.Presale || stage == Stage.Crowdsale);
        _wallet.transfer(msg.value);
    }

    /**
     * @dev Called when an external server sends an IFUM token to each buyer at the Distribution stage.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public onlyOwner {
        require(stage == Stage.Distribution);
        token.safeTransfer(to, value);
    }

    /**
     * @dev At the Distribution stage, burn all IFUM tokens owned by the contract.
     */
    function burnAll() public onlyOwner {
        require(stage == Stage.Distribution);
        token.burn(token.balanceOf(this));
    }

    /**
     * @dev Change the contact stage to the next stage.
     * Stages:
     *  0 - Prepare
     *  1 - Presale      ---- ICO Start --------------
     *  2 - Crowdsale    ---- ICO End ----------------
     *  3 - Distribution
     *  4 - Finished     ---- Unfreeze IFUM Token ----
     */
    function setNextStage() public onlyOwner {
        uint8 intStage = uint8(stage);
        require(intStage < uint8(Stage.Finished));
        intStage++;
        stage = Stage(intStage);
        if (stage == Stage.Finished) {
            token.unfreeze();
        }
        emit SetNextStage(intStage);
    }

    event SetNextStage(uint8 stage);

    event SetWallet(address previousWallet, address newWallet);

    event SetTokenContract(address previousToken, address newToken);
}