-- Set up Warehouse
CREATE OR REPLACE WAREHOUSE COMPUTE_LOADING WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE;

CREATE OR REPLACE WAREHOUSE COMPUTE_TRANSFORM WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE;

CREATE OR REPLACE WAREHOUSE COMPUTE_BI WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE;

-- Set up Database
CREATE OR REPLACE DATABASE PublicTransportation;

-- set up table
CREATE OR REPLACE TABLE Public.DIM_BUS(
	bus_code int NOT NULL,
	number_of_seat int NOT NULL,
	type nvarchar(10) NOT NULL
);

CREATE OR REPLACE TABLE Public.DIM_BUSSTOP(
	bus_stop_id int NOT NULL,
    route_id int NOT NULL,
	name nvarchar(100) NOT NULL,
	street nvarchar(100) NOT NULL,
	district int NOT NULL,
    latitude float NOT NULL,
	longtitude float NOT NULL,
	arrival_time time(7) NULL
);

CREATE OR REPLACE TABLE Public.DIM_ROUTE(
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

CREATE OR REPLACE TABLE Public.FACT_TRIP(
	trip_id int NOT NULL,
	bus_code int NOT NULL,
    bus_stop_id int NOT NULL,
    stop_time_id int NOT NULL,
    route_id int NOT NULL,
	trip_headsign nvarchar(150) NOT NULL,
    date_stop date NOT NULL,
	time_stop time(7) NOT NULL,
	number_of_ticket int NOT NULL
);

CREATE OR REPLACE TABLE Public.STAGE_BUSSTOP(
	bus_stop_id int NOT NULL,
	name nvarchar(100) NOT NULL,
	street nvarchar(100) NOT NULL,
	district int NOT NULL,
    latitude float NOT NULL,
	longtitude float NOT NULL
);

CREATE OR REPLACE TABLE Public.STAGE_TRIP(
	trip_id int NOT NULL,
	bus_code int NOT NULL,
	trip_headsign nvarchar(150) NOT NULL,
    date_stop date NOT NULL,
	time_stop time(7) NOT NULL,
	number_of_ticket int NOT NULL
);

CREATE OR REPLACE TABLE Public.STAGE_STOPROUTE(
	bus_stop_id int NULL,
	route_id int NULL,
	arrival_time time(7) NULL
);
  
CREATE OR REPLACE TABLE Public.STAGE_STOPTIME(
	stop_time_id int NOT NULL,
	trip_id int NOT NULL,
	bus_stop_id int NOT NULL
);

-- Create csv file format
CREATE FILE FORMAT CSV_FORMAT
TYPE = CSV
FIELD_DELIMITER = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
DATE_FORMAT = 'YYYY-MM-DD';

-- Create Stages
CREATE STAGE UPLOAD_STAGE
FILE_FORMAT = CSV_FORMAT;

CREATE STAGE UNLOAD_STAGE
FILE_FORMAT = CSV_FORMAT;

-- Create Tasks to load data from stage to tables in PublicTransportation DB
USE ROLE ACCOUNTADMIN;

CREATE TASK add_BusCalendar
  WAREHOUSE = TRANSPORT_WH
	SCHEDULE = 'USING CRON 30 11 * * * Asia/Ho_Chi_Minh'
  COMMENT = 'Add BusCalendar TABLE'
AS
COPY INTO BUSCALENDAR_STAGE
FROM @UPLOAD_STAGE/Dim_Calendar.csv.gz;

CREATE TASK add_BusType
  WAREHOUSE = TRANSPORT_WH
  AFTER add_BusCalendar
  COMMENT = 'Add Bustype TABLE'
AS
COPY INTO BUSTYPE_STAGE
FROM @UPLOAD_STAGE/Dim_BusType.csv.gz;

CREATE TASK add_BusRoute
  WAREHOUSE = TRANSPORT_WH
  AFTER add_BusType
  COMMENT = 'Add BusRoute TABLE'
AS
COPY INTO BUSROUTE_STAGE
FROM @UPLOAD_STAGE/Dim_BusRoute.csv.gz;

CREATE TASK add_BusInfo
  WAREHOUSE = TRANSPORT_WH
  AFTER add_BusRoute
  COMMENT = 'Add BusInfo TABLE'
AS
COPY INTO BUSINFO_STAGE
FROM @UPLOAD_STAGE/Dim_BusInfo.csv.gz;

CREATE TASK add_BusTrip
  WAREHOUSE = TRANSPORT_WH
  AFTER add_BusInfo
  COMMENT = 'Add BusTrip TABLE'
AS
COPY INTO BUSTRIP_STAGE
FROM @UPLOAD_STAGE/FACT_BusTrip.csv.gz;

CREATE TASK remove_files_in_upload_stage
  WAREHOUSE = TRANSPORT_WH
  AFTER add_BusTrip
  COMMENT = 'Remove files in upload stage'
AS
REMOVE @UPLOAD_STAGE;

GRANT EXECUTE TASK ON ACCOUNT TO ROLE DE_ROLE;

ALTER TASK add_BusTrip RESUME;
ALTER TASK add_BusInfo RESUME;
ALTER TASK add_BusRoute RESUME;
ALTER TASK add_BusType RESUME;
ALTER TASK add_BusCalendar RESUME;
ALTER TASK remove_files_in_upload_stage RESUME;


