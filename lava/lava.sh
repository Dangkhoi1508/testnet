#!/bin/bash

while true
do

# Logo

echo -e "\033[0;31m"
echo "Website:\e[39m https://nodexcapital.com";
echo "Github:\e[39m  https://github.com/nodexcapital";
echo "Discord:\e[39m https://discord.gg/nodexcapital";
echo "Details : Auto Installer Lava | Chain ID : lava-testnet-1      ";
echo -e "\e[0m"

# Menu

PS3='Select an action: '
options=(
"Install Node"
"Create wallet"
"Check node logs"
"Synchronization via StateSync"
"Synchronization via SnapShot"
"UPDATE"
"Delete Node"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install Node")
echo "*********************"
echo -e "\e[1m\e[35m		Lets's begin\e[0m"
echo "*********************"
echo -e "\e[1m\e[32m	Enter your Validator_Name:\e[0m"
echo "_|-_|-_|-_|-_|-_|-_|"
read Validator_Name
echo "_|-_|-_|-_|-_|-_|-_|"
echo export Validator_Name=${Validator_Name} >> $HOME/.bash_profile
echo export CHAIN_ID="lava-testnet-1" >> $HOME/.bash_profile
source ~/.bash_profile

echo -e "\e[1m\e[32m1. Updating packages and dependencies--> \e[0m" && sleep 1
#UPDATE APT
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop screen unzip bc fail2ban htop -y

echo -e "        \e[1m\e[32m2. Installing GO--> \e[0m" && sleep 1
#INSTALL GO
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "              \e[1m\e[32m3. Downloading and building binaries--> \e[0m" && sleep 1
#INSTALL
cd $HOME
git clone https://github.com/K433QLtr6RA9ExEq/GHFkqmTzpdNLDd6T.git
wget https://lava-binary-upgrades.s3.amazonaws.com/testnet/v0.4.0/lavad
chmod +x lavad
mv lavad $HOME/go/bin/

lavad init $Validator_Name --chain-id $CHAIN_ID

cp $HOME/GHFkqmTzpdNLDd6T/testnet-1/genesis_json/genesis.json $HOME/.lava/config
wget -O $HOME/.lava/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/Lava_Network/addrbook.json"


echo -e "                     \e[1m\e[32m4. Node optimization and improvement--> \e[0m" && sleep 1

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulava\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.lava/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.lava/config/config.toml
peers="3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@prod-pnet-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@prod-pnet-seed-node2.lavanet.xyz:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.lava/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.lava/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.lava/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.lava/config/config.toml





# pruning and indexer
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.lava/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.lava/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.lava/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.lava/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.lava/config/config.toml


sudo tee /etc/systemd/system/lavad.service > /dev/null <<EOF
[Unit]
Description=lava
After=network-online.target

[Service]
User=$USER
ExecStart=$(which lavad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


# start service
sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl restart lavad

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u lavad -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[35mcurl -s localhost:26657/status\e[0m"

break
;;
"Create wallet")
echo "_|-_|-_|-_|-_|-_|-_|"
echo -e "      \e[1m\e[35m Your WalletName:\e[0m"
echo "_|-_|-_|-_|-_|-_|-_|"
read Wallet
echo export Wallet=${Wallet} >> $HOME/.bash_profile
source ~/.bash_profile
lavad keys add $Wallet
echo -e "      \e[1m\e[32m!!!!!!!!!SAVE!!!!!!!!!!!!!!!!SAVE YOUR MNEMONIC PHRASE!!!!!!!!!SAVE!!!!!!!!!!!!!!!!\e[0m'"

break
;;
"Synchronization via StateSync")
SNAP_RPC=https://t-lava.rpc.utsa.tech:443
peers="433be6210ad6350bebebad68ec50d3e0d90cb305@217.13.223.167:60856"
sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.lava/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.lava/config/config.toml
lavad tendermint unsafe-reset-all --home /root/.lava --keep-addr-book
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1500\"/" $HOME/.lava/config/app.toml
systemctl restart lavad && journalctl -u lavad -f -o cat

break
;;
"UPDATE")
echo -e "      \e[1m\e[32m Under Progress\e[0m"
lavad version

break
;;
"Check node logs")
sudo journalctl -u lavad -f -o cat

break
;;
"Synchronization via SnapShot")
echo -e "      \e[1m\e[32m Under Progress\e[0m"

break
;;
"Delete Node")
sudo systemctl stop lavad && \
sudo systemctl disable lavad && \
rm /etc/systemd/system/lavad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf GHFkqmTzpdNLDd6T && \
rm -rf .lava && \
rm -rf $(which lavad)

break
;;
"Exit")
exit
esac
done
done