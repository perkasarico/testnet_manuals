#!/bin/bash
RECORD=$(strided q records list-user-redemption-record --limit 10000 --output json | jq --arg WALLET_ADDRESS "$STRIDE_WALLET_ADDRESS" '.UserRedemptionRecord | map(select(.sender == $WALLET_ADDRESS))')
RECORD_COUNT=$(echo $RECORD | jq length)
echo -e "\e[1m\e[32m$RECORD_COUNT\e[0m claimable records found for sender \e[1m\e[32m$STRIDE_WALLET_ADDRESS\e[0m..."
sleep 3
for row in $(echo "${RECORD}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
   if [ $(_jq '.isClaimable') = true ]
   then
     ZONE=$(echo $(_jq '.hostZoneId'))
     EPOCH=$(echo $(_jq '.epochNumber'))
     SENDER=$(echo $(_jq '.sender'))
     echo -e "Claiming \e[1m\e[32m$ZONE.$EPOCH.$SENDER\e[0m..."
     strided tx stakeibc claim-undelegated-tokens $ZONE $EPOCH $SENDER --chain-id $STRIDE_CHAIN_ID --from $WALLET --yes
     sleep 10
   fi
done
