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
CREATE OR REPLACE FILE FORMAT csv_format
type = csv field_delimiter = ',' field_optionally_enclosed_by='"';

-- Create Trigger

-- Set up Snowpipe
create or replace stage publictransportation.Public.bus_stage;
create or replace stage publictransportation.Public.busstop_stage;
create or replace stage publictransportation.Public.stoproute_stage;
create or replace stage publictransportation.Public.route_stage;
create or replace stage publictransportation.Public.stoptime_stage;
create or replace stage publictransportation.Public.trip_stage;

-- Create Bus pipe
create or replace pipe publictransportation.public.bus_pipe
as
copy into publictransportation.public.DIM_BUS
from (
  select t.$1, t.$3, t.$4
  from @publictransportation.public.bus_stage t
)
file_format = csv_format;

-- Create Route pipe
create or replace pipe publictransportation.public.route_pipe
as
copy into publictransportation.public.DIM_ROUTE
from (
  select t.*
  from @publictransportation.public.route_stage t
)
file_format = csv_format;

-- Create Bus stop pipe
create or replace pipe publictransportation.public.busstop_pipe
as
copy into publictransportation.public.STAGE_BUSSTOP
from (
  select t.*
  from @publictransportation.public.busstop_stage t
)
file_format = csv_format;

-- Create Trip pipe
create or replace pipe publictransportation.public.trip_pipe
as
copy into publictransportation.public.STAGE_TRIP
from (
  select t.*
  from @publictransportation.public.trip_stage t
)
file_format = csv_format;

-- Create Stop route pipe
create or replace pipe publictransportation.public.stoproute_pipe
as
copy into publictransportation.public.STAGE_STOPROUTE
from (
  select t.*
  from @publictransportation.public.stoproute_stage t
)
file_format = csv_format;

-- Create Stop time pipe
create or replace pipe publictransportation.public.stoptime_pipe
as
copy into publictransportation.public.STAGE_STOPTIME
from (
  select t.*
  from @publictransportation.public.stoptime_stage t
)
file_format = csv_format;

-- Task
-- Use ACCOUNTADMIN to create and run tasks
USE ROLE accountadmin;

CREATE OR REPLACE TASK ADD_DIM_BUSSTOP
  WAREHOUSE = COMPUTE_TRANSFORM
  SCHEDULE = '1 minute'
AS
  INSERT OVERWRITE INTO publictransportation.public.DIM_BUSSTOP(bus_stop_id, route_id, name, street, district, latitude, longtitude, arrival_time)
  SELECT bsr.bus_stop_id, bsr.route_id, bsr.name, bsr.street, bsr.district, bsr.latitude, bsr.longtitude, bsr.arrival_time
  FROM (
    select bs.bus_stop_id, bs.name, bs.street, bs.district, bs.latitude, bs.longtitude, sr.route_id, sr.arrival_time
    from publictransportation.public.STAGE_BUSSTOP as bs
    join publictransportation.public.STAGE_STOPROUTE as sr
    on bs.bus_stop_id = sr.bus_stop_id
  ) as bsr;

CREATE OR REPLACE TASK ADD_FACT_TRIP
  WAREHOUSE = COMPUTE_TRANSFORM
  SCHEDULE = '1 minute'
AS
  INSERT OVERWRITE INTO publictransportation.public.FACT_TRIP(trip_id, bus_code, bus_stop_id, stop_time_id, route_id, trip_headsign, date_stop, time_stop, number_of_ticket)
  SELECT tsr.trip_id, tsr.bus_code, tsr.bus_stop_id, tsr.stop_time_id, tsr.route_id, tsr.trip_headsign, tsr.date_stop, tsr.time_stop, tsr.number_of_ticket 
  FROM (
    select t.trip_id, t.bus_code, st.bus_stop_id, st.stop_time_id, sr.route_id, t.trip_headsign, t.date_stop, t.time_stop, t.number_of_ticket 
    from publictransportation.public.STAGE_TRIP as t
    join publictransportation.public.STAGE_STOPTIME as st
    on t.trip_id = st.trip_id
    join publictransportation.public.STAGE_STOPROUTE as sr
    on st.bus_stop_id = sr.bus_stop_id
  ) as tsr;

alter task ADD_DIM_BUSSTOP resume;
alter task ADD_FACT_TRIP resume;
