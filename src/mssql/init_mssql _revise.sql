CREATE DATABASE [PublicTransportation]

USE [PublicTransportation];
GO
CREATE SCHEMA Bus;
GO

CREATE TABLE [Bus].[BusType]
(
      [bus_type_id] INT NOT NULL,
	  [bus_type] VARCHAR(50) NOT NULL,
	  [fare] FLOAT NOT NULL,
	  [fare_status] VARCHAR(50),
	  [modified_date] DATETIME,
CONSTRAINT PK_bustype PRIMARY KEY([bus_type_id]) 
)

CREATE TABLE [Bus].[BusRoute]
(
      [route_id] INT NOT NULL,
	  [route_name] VARCHAR(50) NOT NULL,
	  [bus_type_id] INT NOT NULL,
	  [depart_address] VARCHAR(100) NOT NULL,
	  [number_of_busstop] INT NOT NULL,
	  [standard_duration] INT NOT NULL,
	  [frequency] INT NOT NULL,
	  [route_distance] FLOAT NOT NULL,
	  [operating_start_hour] TIME NOT NULL,
	  [operating_end_hour] TIME NOT NULL,
	  [modified_date] DATETIME,
CONSTRAINT PK_busroute PRIMARY KEY ([route_id])
)

CREATE TABLE [Bus].[BusInfo]
(
      [bus_code] VARCHAR(50) NOT NULL,
	  [route_id] INT NOT NULL,
	  [route_id_status] VARCHAR NOT NULL,
	  [seat_capacity] INT NOT NULL,
	  [max_capacity] INT NOT NULL,
	  [modified_date] DATETIME,
CONSTRAINT PK_businfo PRIMARY KEY ([bus_code])
)

CREATE TABLE [Bus].[BusTrip]
(   
      [trip_id] VARCHAR(50) NOT NULL,
	  [bus_type_id] INT NOT NULL,
	  [bus_code] VARCHAR(50) NOT NULL,
	  [route_id] INT NOT NULL,
	  [date_id] VARCHAR(50) NOT NULL,
	  [date] DATE NOT NULL,
	  [depart_timestamp] TIME NOT NULL,
	  [arrival_timestamp] TIME NOT NULL,
	  [number_of_ticket] INT NOT NULL,
	  [modified_date] DATETIME,
CONSTRAINT [PK_bustrip] PRIMARY KEY ([trip_id])
);

CREATE TABLE [Bus].[BusCalendar]
(
	[date_id] VARCHAR(50) NOT NULL,
	[date] DATE NOT NULL,
	[week_day] VARCHAR(50) NOT NULL,
	[day] TINYINT NOT NULL,
	[month] TINYINT NOT NULL,
	[year] INT NOT NULL,
CONSTRAINT [PK_buscalendar] PRIMARY KEY ([date_id])
);

ALTER TABLE [Bus].[BusRoute]
WITH CHECK
ADD CONSTRAINT [FK_bustype] FOREIGN KEY ([bus_type_id])
REFERENCES [Bus].[BusType]([bus_type_id]);
GO

ALTER TABLE [Bus].[BusRoute] CHECK CONSTRAINT [FK_bustype];
GO

ALTER TABLE [Bus].[BusInfo]
WITH CHECK
ADD CONSTRAINT [FK_routeid] FOREIGN KEY ([route_id])
REFERENCES [Bus].[BusRoute]([route_id]);
GO

ALTER TABLE [Bus].[BusInfo] CHECK CONSTRAINT [FK_routeid];
GO

ALTER TABLE [Bus].[BusTrip]
WITH CHECK
ADD CONSTRAINT [FK_bustypeid] FOREIGN KEY ([bus_type_id])
REFERENCES [Bus].[BusType]([bus_type_id]);
GO

-- Insert calendar data into [BusCalendar]
DECLARE @StartDate  date = '20210101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 2, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    DateID = CONVERT(date, d),
	TheDate = CONVERT(date, d),
	TheDayName = CONVERT(VARCHAR(50), DATENAME(WEEKDAY, d)),
    TheDay = CONVERT(TINYINT, DATEPART(DAY, d)),
    TheMonth = CONVERT(TINYINT, DATEPART(MONTH, d)),
    TheYear = CONVERT(INT, DATEPART(YEAR, d))
  FROM d
)
INSERT INTO [Bus].[BusCalendar]([date_id], [date], [week_day], [day], [month], [year])
SELECT FORMAT (DateID, 'yyyyMMdd') as DateID, TheDate, TheDayName, TheDay,
TheMonth, TheYear FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);



ALTER TABLE [Bus].[BusTrip] CHECK CONSTRAINT [FK_bustypeid]
GO

ALTER TABLE [Bus].[BusTrip]
WITH CHECK
ADD CONSTRAINT [FK_buscode] FOREIGN KEY ([bus_code])
REFERENCES [Bus].[BusInfo]([bus_code])
GO

ALTER TABLE [Bus].[BusTrip] CHECK CONSTRAINT [FK_buscode]
GO

ALTER TABLE [Bus].[BusTrip]
WITH CHECK
ADD CONSTRAINT [FK_dateid] FOREIGN KEY ([date_id])
REFERENCES [Bus].[BusCalendar]([date_id])
GO

ALTER TABLE [Bus].[BusTrip] CHECK CONSTRAINT [FK_dateid]
GO
