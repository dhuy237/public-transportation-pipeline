-- Set up Warehouse
CREATE OR REPLACE WAREHOUSE COMPUTE_LOADING WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE;

CREATE OR REPLACE WAREHOUSE COMPUTE_TRANSFORM WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE;

CREATE OR REPLACE WAREHOUSE COMPUTE_BI WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE;

-- Set up Database
CREATE OR REPLACE DATABASE PublicTransportation;

-- set up table
CREATE OR REPLACE TABLE Public.DIM_BUS(
	bus_code int NOT NULL,
	route_id int NOT NULL,
	number_of_seat int NOT NULL,
	type nvarchar(10) NOT NULL
);

CREATE OR REPLACE TABLE Public.DIM_BUSSTOP(
	bus_stop_id int NOT NULL,
    route_id int NOT NULL,
	name nvarchar(100) NOT NULL,
	street nvarchar(100) NOT NULL,
	district int NOT NULL,
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

CREATE OR REPLACE TABLE Public.DIM_STOPTIME(
	stop_time_id int NOT NULL,
	trip_id int NOT NULL,
	bus_stop_id int NOT NULL
);

CREATE OR REPLACE TABLE Public.FACT_TRIP(
	trip_id int NOT NULL,
	bus_code int NOT NULL,
    route_id int NOT NULL,
	trip_headsign nvarchar(150) NOT NULL,
    date_stop date NOT NULL,
	time_stop time(7) NOT NULL,
	number_of_ticket int NOT NULL
);

-- Create csv file format
CREATE OR REPLACE FILE FORMAT csv_format
type = csv field_delimiter = ',' skip_header = 1 field_optionally_enclosed_by='"';

-- Create Trigger

-- Set up Snowpipe
create or replace stage publictransportation.Public.bus_stage;
create or replace stage publictransportation.Public.busstop_stage;
create or replace stage publictransportation.Public.stoproute_stage;
create or replace stage publictransportation.Public.route_stage;
create or replace stage publictransportation.Public.stoptime_stage;
create or replace stage publictransportation.Public.trip_stage;

create or replace pipe publictransportation.public.bus_pipe
as
copy into publictransportation.public.DIM_BUS
from (
  select t.*
  from @publictransportation.public.bus_stage t
)
file_format = csv_format;


-- Task