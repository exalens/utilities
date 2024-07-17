#!/bin/bash

# Function to check if tcpreplay is installed and install it if not
check_and_install_tcpreplay() {
    if ! command -v tcpreplay &> /dev/null; then
        echo "tcpreplay is not installed. Installing now..."
        if ! sudo apt-get update && sudo apt-get install -y tcpreplay; then
            echo "Failed to install tcpreplay"
            exit 1
        fi
        echo "tcpreplay installed successfully."
    fi
}

# Function to replay the pcap file
replay_pcap() {
    local pcap_filename="$1"
    local interface_name="$2"
    local replay_bandwidth="$3"

    # Check the size of the pcap file
    local file_size
    file_size=$(stat -c%s "$pcap_filename")
    if (( file_size > 1073741824 )); then  # 1GB in bytes
        echo "Warning: The pcap file is larger than 1GB and will not be processed."
        return
    fi

    # Construct the tcpreplay command
    local command=(
        "tcpreplay"
        "--intf1=${interface_name}"
        "--mbps=${replay_bandwidth}"
        "--stats=1"  # Update stats every second
        "$pcap_filename"
    )

    # Execute the tcpreplay command and handle the output for progress updates
    echo "Uploading PCAP file..."
    "${command[@]}" | while IFS= read -r line; do
        line="${line/Test start:/PCAP upload started:}"
        line="${line/Test complete:/PCAP upload completed:}"
        echo "$line"
    done

    echo "PCAP upload completed successfully."
}

# Main script execution
main() {
    read -p "Enter the path to the PCAP file: " pcap_filename
    if [[ ! -f "$pcap_filename" ]]; then
        echo "PCAP file does not exist."
        exit 1
    fi

    read -p "Enter the interface name for PCAP replay: " interface_name
    read -p "Enter the PCAP replay bandwidth (e.g., 50Mbps): " replay_bandwidth

    check_and_install_tcpreplay
    replay_pcap "$pcap_filename" "$interface_name" "$replay_bandwidth"
}

main
