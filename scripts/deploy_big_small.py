from scripts.helpful_scripts import get_account, get_contract, fund_with_link
from brownie import BigSmall, network, config
import time


def deploy_big_small():
    account = get_account()
    casino = BigSmall.deploy(
        get_contract("eth_usd_price_feed").address,
        get_contract("vrf_coordinator").address,
        get_contract("link_token").address,
        config["networks"][network.show_active()]["fee"],
        config["networks"][network.show_active()]["keyhash"],
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("Deployed!")
    return casino


def start_casino():
    account = get_account()
    casino = BigSmall[-1]
    starting_tx = casino.startCasino({"from": account})
    starting_tx.wait(1)
    tx = fund_with_link(casino.address)
    print("The casino has started!")


def enter_big():
    account = get_account()
    casino = BigSmall[-1]
    value = casino.getEntranceFee() + 100000000
    tx = casino.enterBig({"from": account, "value": value})
    tx.wait(1)
    print(
        "You entered the BigSmall casino, where you have bet on the outcome being 'big'!"
    )
    time.sleep(30)
    print(f"The outcome of the last roll is {casino.lastRolled()}.")
    if casino.didWin():
        print(f"The last player won and walked away with {casino.enteredFee() * 2}")
    else:
        print(f"The last player lost! :(")


def enter_small():
    account = get_account()
    casino = BigSmall[-1]
    value = casino.getEntranceFee() + 100000000
    tx = casino.enterSmall({"from": account, "value": value})
    tx.wait(1)
    print(
        "You entered the BigSmall casino, where you have bet on the outcome being 'small'!"
    )
    time.sleep(30)
    print(f"The outcome of the last roll is {casino.lastRolled()}.")
    if casino.didWin():
        print(f"The last player won and walked away with {casino.enteredFee() * 2}")
    else:
        print(f"The last player lost! :(")


def main():
    deploy_big_small()
    start_casino()
