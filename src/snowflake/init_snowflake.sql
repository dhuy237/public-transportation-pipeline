-- Set up Warehouse
CREATE WAREHOUSE COMPUTE_LOADING WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE

CREATE WAREHOUSE COMPUTE_TRANSFORM WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE

CREATE WAREHOUSE COMPUTE_BI WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE

-- Set up Database
CREATE DATABASE PublicTransportation  
CREATE SCHEMA Agency
CREATE SCHEMA Schedule

-- set up table
CREATE TABLE Agency.Agency(
	agency_id int NOT NULL,
	name nvarchar(50) NOT NULL,
	phone_number nvarchar(25) NOT NULL,
	address nvarchar(200) NOT NULL,
	operating_hour_start time(7) NOT NULL,
	operating_hour_end time(7) NOT NULL
)
CREATE TABLE Agency.Agency(
	agency_id int NOT NULL,
	name nvarchar(50) NOT NULL,
	phone_number nvarchar(25) NOT NULL,
	address nvarchar(200) NOT NULL,
	operating_hour_start time(7) NOT NULL,
	operating_hour_end time(7) NOT NULL
);


CREATE TABLE Agency.Bus(
	bus_code int NOT NULL,
	route_id int NOT NULL,
	number_of_seat int NOT NULL,
	type nvarchar(10) NOT NULL
);

CREATE TABLE Schedule.BusStop(
	bus_stop_id int NOT NULL,
	name nvarchar(100) NOT NULL,
	street nvarchar(100) NOT NULL,
	district int NOT NULL,
	latitude float NOT NULL,
	longtitude float NOT NULL
);

CREATE TABLE Schedule.Route(
	route_id int NOT NULL,
	agency_id int NOT NULL,
	route_name nvarchar(50) NOT NULL,
	departure_name nvarchar(50) NOT NULL,
	destination_name nvarchar(50) NOT NULL,
	duration int NOT NULL,
	fare int NOT NULL,
	frequency int NOT NULL,
	number_of_stop int NOT NULL,
	number_of_bus int NOT NULL,
	operating_hour_start time(7) NOT NULL,
	operating_hour_end time(7) NOT NULL,
	distance int NOT NULL
);

CREATE TABLE Schedule.StopRoute(
	bus_stop_id int NULL,
	route_id int NULL,
	arrival_time time(7) NULL
);

CREATE TABLE Schedule.StopTime(
	stop_time_id int NOT NULL,
	trip_id int NOT NULL,
	bus_stop_id int NOT NULL
);

CREATE TABLE Schedule.Trip(
	trip_id int NOT NULL,
	bus_code int NOT NULL,
	trip_headsign nvarchar(150) NOT NULL,
    date_stop date NOT NULL,
	time_stop time(7) NOT NULL,
	number_of_ticket int NOT NULL
);

-- Create Trigger

-- Set up Snowpipe

-- Task