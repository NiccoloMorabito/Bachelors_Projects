import serial
import time

port_name = 'COM4'

ser = serial.Serial(
    port=port_name,\
    baudrate=9600,\
    parity=serial.PARITY_NONE,\
    stopbits=serial.STOPBITS_ONE,\
    bytesize=serial.EIGHTBITS,\
        timeout=0)

light_values = list()


while True:
    
    line = ser.readline().decode('utf-8')
    
    light_value = line.split(",")[0]
    
    try:
        light_value_int = int(light_value)
        light_values.append(light_value_int)
    except:
        time.sleep(0.5)
    
    if (len(light_values) > 20):
        avg = str(sum(light_values) // len(light_values))
        print(light_values)
        print("La media è: " + avg)
        ser.write(avg.encode())
        light_values = list()

print(light_values)

ser.close()