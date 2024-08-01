import logging
from pymodbus.server.sync import StartTcpServer
from pymodbus.datastore import ModbusSequentialDataBlock, ModbusSlaveContext, ModbusServerContext
from pymodbus.device import ModbusDeviceIdentification
from threading import Timer
import random

# Configure logging
logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.DEBUG)

# Initialize data store with initial values
slave_id = 1
store = {
    slave_id: ModbusSlaveContext(
        di=ModbusSequentialDataBlock(0, [0]*100),   # Discrete Inputs
        co=ModbusSequentialDataBlock(0, [0]*100),   # Coils
        hr=ModbusSequentialDataBlock(0, [0]*100),   # Holding Registers
        ir=ModbusSequentialDataBlock(0, [0]*100)    # Input Registers
    )
}

context = ModbusServerContext(slaves=store, single=False)

# Define Modbus server identity
identity = ModbusDeviceIdentification()
identity.VendorName = 'Exalens'
identity.ProductCode = 'PM'
identity.VendorUrl = 'http://example.com'
identity.ProductName = 'Modbus Simulator'
identity.ModelName = 'Modbus TCP'
identity.MajorMinorRevision = '1.0'

# Generate a random step value for each register and coil to ensure unique patterns
hr_steps = [random.randint(1, 5) for _ in range(100)]
co_steps = [random.randint(1, 5) for _ in range(100)]

# Update function for continuous process simulation
def update_context(a):
    log.debug("Updating context")
    # Continuous process logic for holding registers
    hr_values = context[slave_id].getValues(3, 0, 100)
    new_hr_values = [(value + step) % 100 for value, step in zip(hr_values, hr_steps)]
    context[slave_id].setValues(3, 0, new_hr_values)
    
    # Continuous process logic for coils
    co_values = context[slave_id].getValues(1, 0, 100)
    new_co_values = [(coil + step) % 2 for coil, step in zip(co_values, co_steps)]  # Toggle each coil state uniquely
    context[slave_id].setValues(1, 0, new_co_values)

# Set up periodic context update (continuous process simulation)
def run_continuous_update():
    update_context(None)
    Timer(1.0, run_continuous_update).start()

run_continuous_update()

# Start the server
if __name__ == "__main__":
    StartTcpServer(context, identity=identity, address=("0.0.0.0", 502))
