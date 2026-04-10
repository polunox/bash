#!/bin/bash

# Configuration directory
CONF_DIR=$(pwd)

# Total traffic volume
total_rx=0
total_tx=0

# Summary
printf "%-22s %-22s %-12s %-15s %-20s\n" \
    "Config name" "External address" "Received" "Transmitted" "Last handshake"

printf '%s\n' "---------------------------------------------------------------------------------------------------------------"

# Read and sort peers by total traffic
while read -r interface public_key preshared_key endpoint allowed_ips latest_handshake transfer_rx transfer_tx persistent_keepalive; do

    # Find the config name by matching the preshared key
    file_path=$(grep -ir "$preshared_key" "$CONF_DIR"/*.conf | cut -d ":" -f1)

    if [ -n "$file_path" ]; then
        client_name=$(basename "$file_path" .conf)
    else
        client_name="${preshared_key:0:8}..."
    fi

    # Last handshake time
    if [ "$latest_handshake" -eq 0 ]; then
        last_seen="never"
    else
        last_seen=$(date -d @"$latest_handshake" "+%Y-%m-%d %H:%M:%S")
    fi

    # Total traffic in bytes
    total_rx=$((total_rx + transfer_rx))
    total_tx=$((total_tx + transfer_tx))

    # Human-readable format
    rx=$(numfmt --to=iec "$transfer_rx")
    tx=$(numfmt --to=iec "$transfer_tx")

    # If the endpoint is empty
    [ "$endpoint" = "(none)" ] && endpoint="---"

    # Output
    printf "%-22s %-22s %-12s %-12s %-20s\n" \
        "$client_name" "$endpoint" "$rx" "$tx" "$last_seen"

done < <(
    sudo wg show all dump | tail -n +2 |
    awk '{print $7+$8 "\t" $0}' |
    sort -rn |
    cut -f2-
)

# Final totals
printf '%s\n' "---------------------------------------------------------------------------------------------------------------"
printf "%-22s %-22s %-12s %-12s %-20s\n" \
    "TOTAL" "---" \
    "$(numfmt --to=iec "$total_rx")" \
    "$(numfmt --to=iec "$total_tx")" \
    "---"
