import csv
import os
import shutil
import random
import time
from datetime import datetime

# Set up reference
BEGIN_TIMESTAMP = 1609459200-3600 # January 1, 2021 12:00:00 AM
NOW_TIME = round(datetime.now().timestamp())
no_of_bus = 100
no_of_ebus = 120
no_of_route = 20
BUS_CODE = [['B' + f'{i:03d}' for i in range(1, no_of_bus+1)], ['E' + f'{i:03d}' for i in range(1, no_of_ebus+1)]]
ROUTE_ID = [[], []]
BUS_INFO = {}

time_stamp = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")

# Set up file path
home_path = os.getenv('USERPROFILE')
dir_path = os.path.dirname(os.path.abspath(__file__))
project_path = home_path + '\\project'
snowPut_path = dir_path + '\\snowPut.bat'
ssisPut_path = dir_path + '\\ssisPut.sql'
snowGet_path = dir_path + '\\snowGet.bat'
ssisGet_path = dir_path + '\\ssisGet.sql'
raw_folder_path = project_path + '\\raw-folder'
work_folder_path = project_path + '\\work-folder'
log_folder_path = project_path + '\\log-folder'
buffer_folder_path = project_path + '\\buffer-folder'
bus_info_path = f'{raw_folder_path}\\BusInfo.csv'
bus_type_path = f'{raw_folder_path}\\BusType.csv'
bus_route_path = f'{raw_folder_path}\\BusRoute.csv'
bus_trip_path = f'{raw_folder_path}\\BusTrip.csv'

def is_rush_hour(time_string):
    start_time = time.strptime(time_string, '%H:%M:%S')
    morning1 = time.strptime('08:00:00', '%H:%M:%S')
    morning2 = time.strptime('09:00:00', '%H:%M:%S')
    evening1 = time.strptime('15:00:00', '%H:%M:%S')
    evening2 = time.strptime('19:00:00', '%H:%M:%S')
    return ((morning1 <= start_time) and (start_time <= morning2)) or ((evening1 <= start_time) and (start_time <= evening2))

def create_bus_type():
    with open(bus_type_path, 'w', newline='') as csvFile:
        fieldnames = ['bus_type_id','bus_type', 'fare']
        writer = csv.DictWriter(csvFile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerow({'bus_type_id': 1, 'bus_type': 'Bus', 'fare': 2.75})
        writer.writerow({'bus_type_id': 2, 'bus_type': 'Express Bus', 'fare': 6.75})
                    

def create_bus_route(no_of_route=20):
    random.seed(0)
    with open(bus_route_path, 'w', newline='') as csvFile:
        fieldnames = ['route_id','route_name', 'bus_type_id', 'depart_address', 'number_of_bustop','standard_duration',
                      'frequency', 'route_distance', 'operating_start_hour', 'operating_end_hour']
        writer = csv.DictWriter(csvFile, fieldnames=fieldnames)
        writer.writeheader()
        for i in range (1, no_of_route+1):
            prefix_route = 'BR' if i<=10 else 'ER'
            route_id = prefix_route + f'{i:02d}'
            if prefix_route == 'BR':
                ROUTE_ID[0].append(route_id)
            else:
                ROUTE_ID[1].append(route_id)
            standard_duration = random.choice([120, 130]) if prefix_route == 'BR' else random.choice([80, 90])
            writer.writerow(
                {
                    'route_id': route_id,
                    'route_name': 'AB_'+route_id,
                    'bus_type_id': 1 if prefix_route=='BR' else 2,
                    'depart_address': 'Manhattan',
                    'number_of_bustop': random.randint(14, 20) if prefix_route == 'BR' else random.randint(4, 10),
                    'standard_duration': standard_duration,
                    'frequency': 30 if prefix_route == 'BR' else 15,
                    'route_distance': round((20 if prefix_route == 'BR' else 30) * standard_duration/60, 1),
                    'operating_start_hour': '06:00:00',
                    'operating_end_hour': '20:00:00'
                }
            )
        
def create_bus_info():
    random.seed(0)
    with open(bus_info_path, 'w', newline='') as csvFile:
        fieldnames = ['bus_code','route_id', 'seat_capacity', 'max_capacity']     
        writer = csv.DictWriter(csvFile, fieldnames=fieldnames)
        writer.writeheader()
        # Map bus to route_id
        for bus in BUS_CODE[0]:
            route_id = random.choice(ROUTE_ID[0])
            BUS_INFO[bus] = route_id
            writer.writerow(
                {
                    'bus_code': bus,
                    'route_id': route_id,
                    'seat_capacity': 70,
                    'max_capacity': 80
                }
            )
        # Map Ebus to route_id
        for ebus in BUS_CODE[1]:
            eroute_id = random.choice(ROUTE_ID[1])
            BUS_INFO[ebus] = eroute_id
            writer.writerow(
                {
                    'bus_code': ebus,
                    'route_id': eroute_id,
                    'seat_capacity': 50,
                    'max_capacity': 55
                }
            )

def create_bus_trip():
    random.seed(0)
    start_timestamp = 1609455600
    bus_a , bus_b = BUS_CODE[0][:no_of_bus//2], BUS_CODE[0][no_of_bus//2:]
    #busy_bus_a, busy_bus_b = [], []
    ebus_a, ebus_b =   BUS_CODE[1][:no_of_ebus//2], BUS_CODE[1][no_of_ebus//2:]
    #busy_ebus_a, busy_ebus_b = [], []
    with open(bus_trip_path, 'w', newline='') as csvFile:
        fieldnames = ['trip_id','bus_type','bus_code', 'route_id','date_id',
                      'date', 'depart_time', 'arrival_time', 'number_of_ticket', 'is_rush_hour']
        writer = csv.DictWriter(csvFile, fieldnames=fieldnames)
        writer.writeheader()
        
        while (start_timestamp + int(16.5*3600) < NOW_TIME):
            # trip for bus
            tracking_timestamp = start_timestamp 
            for i in range(1, 30):
                if i % 5 == 1:
                    active_bus_a = bus_a[:10]
                    active_bus_b = bus_b[:10]
                elif i % 5 == 2:
                    active_bus_a = bus_a[10:20]
                    active_bus_b = bus_b[10:20]
                elif i % 5 == 3:
                    active_bus_a = bus_a[20:30]
                    active_bus_b = bus_b[20:30]
                elif i % 5 == 4:
                    active_bus_a = bus_a[30:40]
                    active_bus_b = bus_b[30:40]
                else:
                    active_bus_a = bus_a[40:]
                    active_bus_b = bus_b[40:]
                for j in range(0, 10):
                    start_datetime = datetime.fromtimestamp(tracking_timestamp)
                    depart_time = start_datetime.strftime("%H:%M:%S")
                    rush_hour = is_rush_hour(depart_time)
                    arrival_datetime_a = datetime.fromtimestamp(tracking_timestamp + random.randint(130*60, 140*60)) if rush_hour else datetime.fromtimestamp(tracking_timestamp + random.randint(115*60, 135*60))
                    # trip bus from A
                    running_bus_a = active_bus_a[j]
                    route_id_a = BUS_INFO[running_bus_a]
                    writer.writerow(
                        {
                            'trip_id':running_bus_a+ '_' +str(tracking_timestamp),
                            'bus_type': 1,
                            'bus_code': running_bus_a,
                            'route_id': route_id_a,
                            'date_id': start_datetime.strftime("%Y%m%d"),
                            'date': start_datetime.strftime("%Y-%m-%d"),
                            'depart_time': depart_time,
                            'arrival_time': arrival_datetime_a.strftime("%H:%M:%S"),
                            'number_of_ticket': random.randint(140, 160) if rush_hour else random.randint(100, 120),
                            'is_rush_hour': rush_hour

                        }
                    )
                    # trip bus from B
                    # depart_time = start_datetime.strftime("%H:%M:%S")
                    arrival_datetime_b = datetime.fromtimestamp(tracking_timestamp + random.randint(130*60, 140*60)) if rush_hour else datetime.fromtimestamp(tracking_timestamp + random.randint(115*60, 135*60))
                    running_bus_b = active_bus_b[j]
                    route_id_b = BUS_INFO[running_bus_b]
                    writer.writerow(
                        {
                            'trip_id':running_bus_b+ '_' +str(tracking_timestamp),
                            'bus_type': 1,
                            'bus_code': running_bus_b,
                            'route_id': route_id_b,
                            'date_id': start_datetime.strftime("%Y%m%d"),
                            'date': start_datetime.strftime("%Y-%m-%d"),
                            'depart_time': depart_time,
                            'arrival_time': arrival_datetime_b.strftime("%H:%M:%S"),
                            'number_of_ticket': random.randint(140, 160) if rush_hour else random.randint(100, 120),
                            'is_rush_hour': rush_hour
                        }
                    )
                tracking_timestamp += 30*60
            # trip for express bus
            etracking_timestamp = start_timestamp
            for i in range(1, 58):
                if i % 6 == 1:
                    active_ebus_a = ebus_a[:10]
                    active_ebus_b = ebus_b[:10]
                elif i % 6 == 2:
                    active_ebus_a = ebus_a[10:20]
                    active_ebus_b = ebus_b[10:20]
                elif i % 6 == 3:
                    active_ebus_a = ebus_a[20:30]
                    active_ebus_b = ebus_b[20:30]
                elif i % 6 == 4:
                    active_ebus_a = ebus_a[30:40]
                    active_ebus_b = ebus_b[30:40]
                elif i % 6 == 5:
                    active_ebus_a = ebus_a[40:50]
                    active_ebus_b = ebus_b[40:50]
                else:
                    active_ebus_a = ebus_a[50:]
                    active_ebus_b = ebus_b[50:]
                for j in range(0, 10):
                    start_datetime = datetime.fromtimestamp(etracking_timestamp)
                    depart_time = start_datetime.strftime("%H:%M:%S")
                    rush_hour = is_rush_hour(depart_time)
                    arrival_datetime_a = datetime.fromtimestamp(etracking_timestamp + random.randint(95*60, 100*60)) if rush_hour else datetime.fromtimestamp(etracking_timestamp + random.randint(75*60, 95*60))
                    # trip bus from A
                    running_ebus_a = active_ebus_a[j]
                    route_id_a = BUS_INFO[running_ebus_a]
                    writer.writerow(
                        {
                            'trip_id':running_ebus_a+ '_' +str(etracking_timestamp),
                            'bus_type': 2,
                            'bus_code': running_ebus_a,
                            'route_id': route_id_a,
                            'date_id': start_datetime.strftime("%Y%m%d"),
                            'date': start_datetime.strftime("%Y-%m-%d"),
                            'depart_time': depart_time,
                            'arrival_time': arrival_datetime_a.strftime("%H:%M:%S"),
                            'number_of_ticket': random.randint(100, 110) if rush_hour else random.randint(60, 90),
                            'is_rush_hour': rush_hour
                        }
                    )
                    # trip bus from B
                    # depart_time = start_datetime.strftime("%H:%M:%S")
                    arrival_datetime_a = datetime.fromtimestamp(etracking_timestamp + random.randint(95*60, 100*60)) if rush_hour else datetime.fromtimestamp(etracking_timestamp + random.randint(75*60, 95*60))
                    running_ebus_b = active_ebus_b[j]
                    route_id_b = BUS_INFO[running_ebus_b]
                    writer.writerow(
                        {
                            'trip_id':running_ebus_b+ '_' +str(etracking_timestamp),
                            'bus_type': 2,
                            'bus_code': running_ebus_b,
                            'route_id': route_id_b,
                            'date_id': start_datetime.strftime("%Y%m%d"),
                            'date': start_datetime.strftime("%Y-%m-%d"),
                            'depart_time': depart_time,
                            'arrival_time': arrival_datetime_a.strftime("%H:%M:%S"),
                            'number_of_ticket': random.randint(100, 110) if rush_hour else random.randint(60, 90),
                            'is_rush_hour': rush_hour
                        }
                    )
                etracking_timestamp += 15*60
            start_timestamp += 86400

if __name__ == '__main__':
    t1 = datetime.now()
    print('Creating data...')
    if not os.path.isdir(project_path):
        os.mkdir(project_path)
    if not os.path.isdir(raw_folder_path):
        os.mkdir(raw_folder_path)
    if not os.path.isdir(work_folder_path):
        os.mkdir(work_folder_path)
    if not os.path.isdir(log_folder_path):
        os.mkdir(log_folder_path)
    if not os.path.isdir(buffer_folder_path):
        os.mkdir(buffer_folder_path)

    try:
        shutil.copy(ssisPut_path, project_path)
        shutil.copy(ssisGet_path, project_path)
        shutil.copy(snowPut_path, project_path)
        shutil.copy(snowGet_path, project_path)
        print("Files copied successfully.")
 
    # If source and destination are same
    except shutil.SameFileError:
        print("Source and destination represents the same file.")
    
    # If destination is a directory.
    except IsADirectoryError:
        print("Destination is a directory.")
    
    # If there is any permission issue
    except PermissionError:
        print("Permission denied.")
    
    # For other errors
    except:
        print("Error occurred while copying file.")

    create_bus_type()
    create_bus_route()
    create_bus_info()
    create_bus_trip()
    t2 = datetime.now()
    print(f"Done in time {t2-t1}")