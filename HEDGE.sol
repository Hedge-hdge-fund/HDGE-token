// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^4.0.0
// Project website: https://www.hdge.fund
// X @InvestinHedge
// Youtube @ InvestinHedge
// Telegram @hdgefund
pragma solidity ^0.8.2;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Hedge is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, UUPSUpgradeable {
    address public taxWallet;
    uint256 public constant taxRate = 5; // 0.5%
    bool public initialTransferComplete;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _taxWallet) initializer public {
        __ERC20_init("Hedge", "HDGE");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init("Hedge");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();

        taxWallet = _taxWallet;

        _mint(initialOwner, 100000000 * 10 ** decimals());
        initialTransferComplete = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable, ERC20VotesUpgradeable)
    {
        if (initialTransferComplete) {
            uint256 tax = value * taxRate / 1000;
            uint256 amountAfterTax = value - tax;
            super._update(from, to, amountAfterTax);
            super._update(from, taxWallet, tax);
        } else {
            super._update(from, to, value);
            initialTransferComplete = true;
        }
    }

    function nonces(address owner)
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}