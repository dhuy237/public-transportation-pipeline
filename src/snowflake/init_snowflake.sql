-- Set up Warehouse
CREATE OR REPLACE WAREHOUSE TRANSPORT_WH WITH
WAREHOUSE_SIZE = 'SMALL'
MAX_CLUSTER_COUNT = 2
MIN_CLUSTER_COUNT = 1
AUTO_SUSPEND = 600
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = FALSE
COMMENT = 'This warehouse is used for transportation project demo.';

DROP TABLE FACT_BUSTRIP
-- Set up Database
CREATE OR REPLACE DATABASE PublicTransportation;

-- set up table

CREATE OR REPLACE TABLE DIM_BUSTYPE
(
	bus_type_id INT NOT NULL,
	bus_type VARCHAR(50) NOT NULL,
  modifiled_date DATETIME NOT NULL
);

CREATE OR REPLACE TABLE DIM_BUSROUTE
(
	route_id VARCHAR(50)  NOT NULL,
	route_name VARCHAR(50) NOT NULL,
	depart_address VARCHAR(50) NOT NULL,
  frequency INT NOT NULL,
	operating_start_hour TIME NOT NULL,
  operating_end_hour TIME NOT NULL,
  modifiled_date DATETIME NOT NULL
);


CREATE OR REPLACE TABLE DIM_BUSINFO
(
	bus_code VARCHAR(50) NOT NULL,
	seat_capacity INT NOT NULL,
	max_capacity INT NOT NULL,
  modifiled_date DATETIME NOT NULL
);

CREATE OR REPLACE TABLE DIM_BUSCALENDAR
(
  date_id VARCHAR(50) NOT NULL,
  date DATE NOT NULL,
  week_day VARCHAR(50) NOT NULL,
  day TINYINT NOT NULL,
  month TINYINT NOT NULL,
  year INT NOT NULL
);

CREATE OR REPLACE TABLE FACT_BUSTRIP(
  trip_id VARCHAR(50) NOT NULL,
  bus_code VARCHAR(50) NOT NULL,
  route_id VARCHAR(50) NOT NULL,
  bus_type_id INT NOT NULL,
  date_id VARCHAR(50) NOT NULL,
  date DATE NOT NULL,
  depart_time TIME NOT NULL,
  arrival_time TIME NOT NULL,
  is_rush_hour VARCHAR(50) NOT NULL,
  real_duration FLOAT NOT NULL,
  standard_duration INT NOT NULL,
  status VARCHAR(50) NOT NULL,
  number_of_busstop INT NOT NULL,
  route_distance FLOAT NOT NULL,
  average_velocity FLOAT NOT NULL,
  number_of_ticket INT NOT NULL,
  fare FLOAT NOT NULL,
  revenue FLOAT NOT NULL,
  modifiled_date DATETIME NOT NULL
);

-- Create csv file format
CREATE OR REPLACE FILE FORMAT csv_format
type = csv field_delimiter = ',' field_optionally_enclosed_by='"';

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

-- Task for transforming data to before load to DIM_BUSSTOP table
CREATE OR REPLACE TASK ADD_DIM_BUSSTOP
  WAREHOUSE = COMPUTE_TRANSFORM
  SCHEDULE = '30 minute'
AS
  INSERT INTO publictransportation.public.DIM_BUSSTOP(bus_stop_id, route_id, name, street, district, latitude, longtitude, arrival_time)
  SELECT bsr.bus_stop_id, bsr.route_id, bsr.name, bsr.street, bsr.district, bsr.latitude, bsr.longtitude, bsr.arrival_time
  FROM (
    select bs.bus_stop_id, bs.name, bs.street, bs.district, bs.latitude, bs.longtitude, sr.route_id, sr.arrival_time
    from publictransportation.public.STAGE_BUSSTOP as bs
    join publictransportation.public.STAGE_STOPROUTE as sr
    on bs.bus_stop_id = sr.bus_stop_id
  ) as bsr;

-- Task for transforming data to before load to FACT_TRIP table
CREATE OR REPLACE TASK ADD_FACT_TRIP
  WAREHOUSE = COMPUTE_TRANSFORM
  SCHEDULE = '1 minute'
AS
  INSERT INTO publictransportation.public.FACT_TRIP(trip_id, bus_code, bus_stop_id, stop_time_id, route_id, trip_headsign, date_stop, time_stop, number_of_ticket)
  SELECT tsr.trip_id, tsr.bus_code, tsr.bus_stop_id, tsr.stop_time_id, tsr.route_id, tsr.trip_headsign, tsr.date_stop, tsr.time_stop, tsr.number_of_ticket 
  FROM (
    select t.trip_id, t.bus_code, st.bus_stop_id, st.stop_time_id, sr.route_id, t.trip_headsign, t.date_stop, t.time_stop, t.number_of_ticket 
    from publictransportation.public.STAGE_TRIP as t
    join publictransportation.public.STAGE_STOPTIME as st
    on t.trip_id = st.trip_id
    join publictransportation.public.STAGE_STOPROUTE as sr
    on st.bus_stop_id = sr.bus_stop_id
  ) as tsr;

-- Task to remove stage table STAGE_BUSSTOP
CREATE TASK REMOVE_STAGE_DIM_BUSSTOP
  WAREHOUSE = COMPUTE_TRANSFORM
  AFTER ADD_DIM_BUSSTOP
AS
DELETE FROM publictransportation.public.STAGE_BUSSTOP;

-- Task to remove stage table STAGE_TRIP
CREATE TASK REMOVE_STAGE_FACT_TRIP
  WAREHOUSE = COMPUTE_TRANSFORM
  AFTER ADD_FACT_TRIP
AS
DELETE FROM publictransportation.public.STAGE_TRIP;

-- Task to remove stage table STAGE_STOPTIME
CREATE TASK REMOVE_STAGE_STOPTIME
  WAREHOUSE = COMPUTE_TRANSFORM
  AFTER ADD_FACT_TRIP
AS
DELETE FROM publictransportation.public.STAGE_STOPTIME;

-- Task to remove stage table STAGE_STOPROUTE
CREATE TASK REMOVE_STAGE_STOPROUTE
  WAREHOUSE = COMPUTE_TRANSFORM
  AFTER ADD_FACT_TRIP
AS
DELETE FROM publictransportation.public.STAGE_STOPROUTE;

alter task REMOVE_STAGE_DIM_BUSSTOP resume;
alter task REMOVE_STAGE_FACT_TRIP resume;
alter task REMOVE_STAGE_STOPTIME resume;
alter task REMOVE_STAGE_STOPROUTE resume;
alter task ADD_DIM_BUSSTOP resume;
alter task ADD_FACT_TRIP resume;