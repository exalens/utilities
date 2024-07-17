#!/bin/bash

# Function to check if an interface exists
interface_exists() {
    ip link show "$1" &> /dev/null
    return $?
}

# Prompt the user for the interface name
read -p "Enter the interface name for PCAP replay interface: " interface_name

# Function to create and configure a dummy interface
create_dummy_interface() {
    local interface_name="$1"
    
    if ! interface_exists "$interface_name"; then
        # Add the dummy interface
        sudo ip link add "$interface_name" type dummy
        echo "PCAP replay interface '$interface_name' created."
    else
        echo "PCAP replay interface '$interface_name' already exists."
    fi

    # Set the interface to promiscuous mode
    sudo ip link set "$interface_name" promisc on
    # Disable ARP on the interface
    sudo ip link set "$interface_name" arp off
    # Disable multicast by setting the 'allmulticast' flag off
    sudo ip link set "$interface_name" allmulticast off
    # Bring the interface up
    sudo ip link set "$interface_name" up
    # Enable jumbo frames
    sudo ip link set "$interface_name" mtu 9000
    
    echo "PCAP replay interface '$interface_name' configured successfully."
}

# Execute the function with the user-provided interface name
create_dummy_interface "$interface_name"
