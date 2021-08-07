import csv
import os
import random
import string
from datetime import datetime
from decimal import Decimal
from faker import Faker

fake = Faker()


def create_csv_file_Order_Line():
    time_stampe = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
    raw_path = os.path.dirname(__file__)
   # with open(f'{raw_path}\hitData-{time_stampe}.csv', 'w', newline='') as csvfile:
    with open(f'C:\\Users\\Ha Quyen\\Documents\\test\\bus_station.csv', 'w', newline='') as csvfile:
        fieldnames = ['bus_station_id','route_id','address','street_name']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 100
        writer.writeheader()
        for i in range(RECORD_COUNT):
            writer.writerow(
                {
                    'bus_station_id': fake.random_int(5000,5099),
                    'route_id': fake.random_int(1,50),
                    'address': fake.address(),
                    'street_name':fake.street_name()
                }
            )
with open(f'C:\\Users\\Ha Quyen\\Documents\\test\\route.csv', 'w', newline='') as csvfile:
        fieldnames = ['route_id','departure_name','destination_name','distance','duration','frequency','fare','total_number_of_trip']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 50
        writer.writeheader()
        for i in range(RECORD_COUNT):
            writer.writerow(
                {
                    
                    'route_id': i,
                    'departure_name': fake.street_name(),
                    'destination_name': fake.street_name(),
                    'distance':fake.random_int(1,15),
                    'duration': fake.random_int(100,120),
                    'frequency': fake.random_int(5,10),
                    'fare': fake.random_int(5,10),
                    'total_number_of_trip': fake.random_int(150,250),
                    
            
                }
            )
         
with open(f'C:\\Users\\Ha Quyen\\Documents\\test\\real_time.csv', 'w', newline='') as csvfile:
        fieldnames = ['time_stamp','route_id','destination','status']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 100
        writer.writeheader()
        for i in range(RECORD_COUNT):
            writer.writerow(
                {
                    'time_stamp': fake.time(),
                    'route_id': fake.random_int(1,50),
                    'destination': fake.street_name(),
                    'status': fake.boolean(chance_of_getting_true=25) 
                }
            )
with open(f'C:\\Users\\Ha Quyen\\Documents\\test\\schedule.csv', 'w', newline='') as csvfile:
        fieldnames = ['departure_name','arrival_name','departure_time','arrival_time','via']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 100
        writer.writeheader()
        for i in range(RECORD_COUNT):
            writer.writerow(
                {
                    'departure_name': fake.street_name(),
                    'arrival_name': fake.street_name(),
                    'departure_time': fake.time(),
                    'arrival_time': fake.time(),
                    'via':fake.street_name()
                }
            )            
with open(f'C:\\Users\\Ha Quyen\\Documents\\test\\bus.csv', 'w', newline='') as csvfile:
        fieldnames = ['bus_code','bus_station_id','number_of_seat']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 1000
        writer.writeheader()
        for i in range(RECORD_COUNT):
            writer.writerow(
                {
                    'bus_code': fake.swift(length=8),
                    'bus_station_id': fake.random_int(5000,5099),
                    'number_of_seat': fake.random_int(40,80)
                    
                }
            )            
if __name__ == '__main__':
    print('Creating a fake data...')
    create_csv_file_Order_Line()


    