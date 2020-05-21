import serial

port = serial.Serial(port='COM1')

while True:
    print("Введите команду")
    print("'e' - вкл/выкл гирлянды")
    print("'m' - выбор режима работы гирлянды")
    print("'s' - изменение скорости (работает только для 2-ого режима)")

    choice = input()

    if choice == 'q':
        break
    elif choice == 'e' or choice == 'm' or choice == 's':
        port.write(bytes(choice, 'ASCII'))
