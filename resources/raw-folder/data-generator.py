import csv
import os
import random
from datetime import datetime
from decimal import Decimal
from faker import Faker
import pandas as pd
import seaborn


def create_bus_stop(output_path, numOfRecords=100, seed_num=0):
    fake = Faker()
    Faker.seed(seed_num)

    filename = output_path+'/bus_stop.csv'
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = ['bus_stop_id', 'name', 'street', 'district', 'latitude', 'longtitude']
        
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for i in range(numOfRecords):
            fake_location_data = fake.local_latlng()
            fake_street_name = fake.street_name()

            writer.writerow(
                {
                    'bus_stop_id': 1000 + i,
                    'name': fake_street_name.split(' ')[0],
                    'street': fake_street_name,
                    'district': fake.random_int(1, 12),
                    'latitude': fake_location_data[0],
                    'longtitude': fake_location_data[1]
                }
            )
    return filename

def create_route(output_path, numOfRecords=20, seed_num=0):
    fake = Faker()
    Faker.seed(seed_num)

    filename = output_path+'/route.csv'
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = ['route_id', 'agency_id', 'route_name', 'departure_name', 'destination_name', 
                      'duration', 'fare', 'frequency', 'number_of_stop', 'number_of_bus', 'operating_hour', 'distance']

        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for i in range(numOfRecords):
            departure_name = fake.street_name()
            destination_name = fake.street_name()

            writer.writerow(
                {
                    'route_id': i + 1,
                    'agency_id': fake.random_int(100, 100 + numOfRecords),
                    'route_name': departure_name + " - " + destination_name,
                    'departure_name': departure_name,
                    'destination_name': destination_name,
                    'duration': fake.random_int(100, 120),
                    'fare': fake.random_int(5, 10),
                    'frequency': fake.random_int(15, 20),
                    'number_of_stop': fake.random_int(10, 20),
                    'operating_hour': fake.random_int(12, 16),
                    'distance': fake.random_int(1, 15)
                }
            )
    return filename

def create_agency(output_path, numOfRecords=20, seed_num=0):
    fake = Faker()
    Faker.seed(seed_num)

    filename = output_path+'/agency.csv'
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = ['agency_id', 'name', 'phone_number', 'address', 'operating_hour']

        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for i in range(numOfRecords):
            departure_name = fake.street_name()
            destination_name = fake.street_name()

            writer.writerow(
                {
                    'agency_id': 100 + i,
                    'name': fake.company(),
                    'phone_number': fake.phone_number(),
                    'address': fake.address(),
                    'operating_hour': fake.random_int(8, 10)
                }
            )
    return filename

def create_bus(output_path, numOfRecords=60, seed_num=0, numOfRouteID=20):
    fake = Faker()
    Faker.seed(seed_num)
    random.seed(seed_num)

    filename = output_path+'/bus.csv'

    bus_dict = {
        'large': 50,
        'normal': 40,
        'small': 30
    }

    with open(filename, 'w', newline='') as csvfile:
        fieldnames = ['bus_code', 'route_id', 'number_of_seat', 'type']

        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for i in range(numOfRecords):
            bus_type, bus_seat = random.choice(list(bus_dict.items()))
            writer.writerow(
                {
                    'bus_code': 100 + i,
                    'route_id': fake.random_int(1, numOfRouteID),
                    'number_of_seat': bus_seat,
                    'type': bus_type
                }
            )
    return filename