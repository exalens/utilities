#!/bin/bash

# Function to run a command and handle errors
run_command() {
    local command="$1"
    if ! eval "$command"; then
        echo "Error executing: $command" >&2
        exit 1
    fi
}

# Function to ensure directories and files exist
ensure_directory() {
    local directories=(
        "/etc/iptables:rules.v4:rules.v6"
        "/etc/ebtables:rules-save"
    )

    for entry in "${directories[@]}"; do
        IFS=":" read -r path files <<< "$entry"
        if [ ! -d "$path" ]; then
            sudo mkdir -p "$path"
        fi
        for file in $files; do
            if [ ! -f "$path/$file" ]; then
                sudo touch "$path/$file"
            fi
        done
    done
}

# Function to set monitoring configuration
set_monitoring() {
    local interface="$1"
    ensure_directory
    # Enable promiscuous mode
    run_command "sudo ip link set $interface promisc on"
    # Disable ARP
    run_command "sudo ip link set $interface arp off"
    # Block all inbound and outbound IPv4 and IPv6 connections via iptables and ip6tables
    run_command "sudo iptables -I INPUT -i $interface -j DROP"
    run_command "sudo iptables -I OUTPUT -o $interface -j DROP"
    run_command "sudo ip6tables -I INPUT -i $interface -j DROP"
    run_command "sudo ip6tables -I OUTPUT -o $interface -j DROP"
    # Save iptables and ip6tables rules
    run_command "sudo iptables-save > /etc/iptables/rules.v4"
    run_command "sudo ip6tables-save > /etc/iptables/rules.v6"
    # Block outbound frames using ebtables
    run_command "sudo ebtables -A OUTPUT -o $interface -j DROP"
    run_command "sudo ebtables-save > /etc/ebtables/rules-save"
    echo "Monitoring configuration successfully set for $interface"
}

# Function to remove monitoring configuration
remove_monitoring() {
    local interface="$1"
    ensure_directory
    # Disable promiscuous mode
    run_command "sudo ip link set $interface promisc off"
    # Enable ARP
    run_command "sudo ip link set $interface arp on"
    # Remove iptables and ip6tables rules
    run_command "sudo iptables -D INPUT -i $interface -j DROP"
    run_command "sudo iptables -D OUTPUT -o $interface -j DROP"
    run_command "sudo ip6tables -D INPUT -i $interface -j DROP"
    run_command "sudo ip6tables -D OUTPUT -o $interface -j DROP"
    # Save iptables and ip6tables rules
    run_command "sudo iptables-save > /etc/iptables/rules.v4"
    run_command "sudo ip6tables-save > /etc/iptables/rules.v6"
    # Remove ebtables rules
    run_command "sudo ebtables -D OUTPUT -o $interface -j DROP"
    run_command "sudo ebtables-save > /etc/ebtables/rules-save"
    echo "Monitoring configuration successfully removed for $interface"
}

# Main script execution
main() {
    read -p "Enter the interface name: " interface_name
    read -p "Would you like to set or remove the monitoring configuration? (set/remove): " action

    if [ "$action" == "set" ]; then
        set_monitoring "$interface_name"
    elif [ "$action" == "remove" ]; then
        remove_monitoring "$interface_name"
    else
        echo "Please specify 'set' or 'remove'"
        exit 1
    fi
}

main
