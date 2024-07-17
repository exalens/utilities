import subprocess

def interface_exists(interface_name):
    result = subprocess.run(['ip', 'link', 'show', interface_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode == 0

def create_dummy_interface():
    interface_name = 'pcap_replay'
    try:
        if not interface_exists(interface_name):
            # Add the dummy interface
            subprocess.run(['sudo', 'ip', 'link', 'add', interface_name, 'type', 'dummy'], check=True)
            print(f"Dummy interface '{interface_name}' created.")
        else:
            print(f"Dummy interface '{interface_name}' already exists.")

        # Set the interface to promiscuous mode
        subprocess.run(['sudo', 'ip', 'link', 'set', interface_name, 'promisc', 'on'], check=True)
        # Disable ARP on the interface
        subprocess.run(['sudo', 'ip', 'link', 'set', interface_name, 'arp', 'off'], check=True)
        # Disable multicast by setting the 'allmulticast' flag off
        subprocess.run(['sudo', 'ip', 'link', 'set', interface_name, 'allmulticast', 'off'], check=True)
        # Bring the interface up
        subprocess.run(['sudo', 'ip', 'link', 'set', interface_name, 'up'], check=True)
        # Enable jumbo frames
        subprocess.run(['sudo', 'ip', 'link', 'set', interface_name, 'mtu', '9000'], check=True)
        
        print(f"Dummy interface '{interface_name}' configured successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to create or configure the dummy interface: {str(e)}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    create_dummy_interface()
