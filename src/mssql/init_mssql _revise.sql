--Create database
CREATE DATABASE [PublicTransportation];
GO
USE [PublicTransportation];
GO
CREATE SCHEMA [Bus];
GO

--Create tables for schema Bus

CREATE TABLE [Bus].[BusType]
(
      [bus_type_id] INT NOT NULL,
	  [bus_type] VARCHAR(50) NOT NULL,
	  [fare] FLOAT NOT NULL,
	  [fare_status] VARCHAR(50),
	  [modified_date] DATETIME,
CONSTRAINT PK_bustype PRIMARY KEY([bus_type_id]) 
);

CREATE TABLE [Bus].[BusRoute]
(
      [route_id] VARCHAR(50) NOT NULL,
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
);

CREATE TABLE [Bus].[BusInfo]
(
      [bus_code] VARCHAR(50) NOT NULL,
	  [route_id] VARCHAR(50) NOT NULL,
	  [route_id_status] VARCHAR(50) NOT NULL,
	  [seat_capacity] INT NOT NULL,
	  [max_capacity] INT NOT NULL,
	  [modified_date] DATETIME,
CONSTRAINT PK_businfo PRIMARY KEY ([bus_code])
);


CREATE TABLE [Bus].[BusTrip]
(   
      [trip_id] VARCHAR(50) NOT NULL,
	  [bus_code] VARCHAR(50) NOT NULL,
	  [date_id] VARCHAR(50) NOT NULL,
	  [date] DATE NOT NULL,
	  [depart_time] TIME(0) NOT NULL,
	  [arrival_time] TIME(0) NOT NULL,
	  [number_of_ticket] INT NOT NULL,
	  [is_rush_hour] VARCHAR(50) NOT NULL,
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


-- Add constraints
---BusRoute
ALTER TABLE [Bus].[BusRoute]
WITH CHECK
ADD CONSTRAINT [FK_bustype] FOREIGN KEY ([bus_type_id])
REFERENCES [Bus].[BusType]([bus_type_id]);
GO

ALTER TABLE [Bus].[BusRoute] CHECK CONSTRAINT [FK_bustype];
GO

---BusInfo
ALTER TABLE [Bus].[BusInfo]
WITH CHECK
ADD CONSTRAINT [FK_routeid] FOREIGN KEY ([route_id])
REFERENCES [Bus].[BusRoute]([route_id]);
GO

ALTER TABLE [Bus].[BusInfo] CHECK CONSTRAINT [FK_routeid];
GO

---BusTrip
ALTER TABLE [Bus].[BusTrip]
WITH CHECK
ADD CONSTRAINT [FK_buscode] FOREIGN KEY ([bus_code])
REFERENCES [Bus].[BusInfo]([bus_code]);
GO

ALTER TABLE [Bus].[BusTrip] CHECK CONSTRAINT [FK_buscode];
GO

ALTER TABLE [Bus].[BusTrip]
WITH CHECK
ADD CONSTRAINT [FK_dateid] FOREIGN KEY ([date_id])
REFERENCES [Bus].[BusCalendar]([date_id]);
GO

ALTER TABLE [Bus].[BusTrip] CHECK CONSTRAINT [FK_dateid];
GO

--Create Views
GO
CREATE VIEW [V_Dim_BusType] AS
SELECT [bus_type_id], [bus_type], [modified_date]
FROM [Bus].[BusType];
GO
CREATE VIEW [V_Dim_BusRoute] AS
SELECT [route_id], [route_name], [depart_address],[frequency],
       [operating_start_hour], [operating_end_hour], [modified_date]
FROM [Bus].[BusRoute];
GO
CREATE VIEW [V_Dim_BusInfo] AS
SELECT [bus_code],
	[seat_capacity],
	[max_capacity],
	[modified_date]
FROM [Bus].[BusInfo];
GO
CREATE VIEW [V_A] AS
SELECT [Bus].[BusInfo].[bus_code],
  [Bus].[BusInfo].[route_id],
  [Bus].[BusRoute].[bus_type_id],
  [Bus].[BusRoute].[number_of_busstop],
  [Bus].[BusRoute].[standard_duration],
  [Bus].[BusRoute].[route_distance],
  B.[fare]
FROM [Bus].[BusInfo]
LEFT JOIN [Bus].[BusRoute] ON [Bus].[BusInfo].[route_id] = [Bus].[BusRoute].[route_id]
LEFT JOIN ( SELECT [Bus].[BusRoute].[route_id], [Bus].[BusType].[fare]
             FROM [Bus].[BusRoute]
			 LEFT JOIN [Bus].[BusType] ON [Bus].[BusRoute].[bus_type_id] = [Bus].[BusType].[bus_type_id]
		  ) B ON [Bus].[BusInfo].[route_id] = B.[route_id] 
;
GO
CREATE VIEW [V_Fact_BusTrip] AS
SELECT [Bus].[BusTrip].[trip_id] AS [trip_id],
       [Bus].[BusTrip].[bus_code] AS [bus_code],
	   [V_A].[route_id] AS [route_id],
	   [V_A].[bus_type_id] AS [bus_type_id],
	   [Bus].[BusCalendar].[date_id] AS [date_id],
	   [Bus].[BusTrip].[date] AS [date],
	   [Bus].[BusTrip].[depart_time] AS [depart_time],
	   [Bus].[BusTrip].[arrival_time] AS [arrival_time],
	   [Bus].[BusTrip].[is_rush_hour] AS [is_rush_hour],
	   DATEDIFF(MINUTE, [depart_time], [arrival_time]) AS [real_duration],
	   [V_A].[standard_duration] AS [standard_duration],
(CASE WHEN DATEDIFF(MINUTE, [depart_time], [arrival_time]) <= [standard_duration] THEN 'ONTIME' ELSE 'LATE' END) AS [status],
       [V_A].[number_of_busstop] AS [number_of_busstop],
	   [V_A].[route_distance] AS [route_distance],
	   ROUND(([route_distance]/(CAST((DATEDIFF(MINUTE, [depart_time], [arrival_time])) AS FLOAT)/60)),2) AS [average_velocity],
	   [Bus].[BusTrip].[number_of_ticket] AS [number_of_ticket],
	   [V_A].[fare] AS [fare],
	   ([number_of_ticket]*[fare]) AS [revenue],
	   [Bus].[BusTrip].[modified_date] AS [modified_date]
FROM [Bus].[BusTrip]
LEFT JOIN [V_A] ON [Bus].[BusTrip].[bus_code] = [V_A].[bus_code]
LEFT JOIN [Bus].[BusCalendar] ON [Bus].[BusTrip].[date_id] = [Bus].[BusCalendar].[date_id]
;
GO
--Create A Log Table To Track Changes To Database Objects
USE [PublicTransportation]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [ChangeLog]
(
    [log_id] [INT] IDENTITY(1,1) NOT NULL,
    [database_name] VARCHAR(256) NOT NULL,
    [event_type] VARCHAR(50) NOT NULL,
    [object_name] VARCHAR(256) NOT NULL,
    [object_type] VARCHAR(25) NOT NULL,
    [sql_command] VARCHAR(MAX) NOT NULL,
    [event_date] DATETIME NOT NULL,
    [login_name] VARCHAR(256) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
 
ALTER TABLE [ChangeLog]
ADD CONSTRAINT [DF_EventsLog_EventDate] DEFAULT (GETDATE()) FOR [event_date];
GO

--Create triggers

--- Create trigger to update [modified_date] for [Bus].[BusType] table
USE [PublicTransportation]
 GO
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TRIGGER [bustype_modified_date] on [Bus].[BusType] AFTER INSERT, UPDATE AS
 BEGIN
     UPDATE [Bus].[BusType]
     SET [modified_date] = CURRENT_TIMESTAMP
     FROM [Bus].[BusType] INNER JOIN inserted i ON [Bus].[BusType].[bus_type_id] = i.[bus_type_id]
 END;
 GO
 ALTER TABLE [Bus].[BusType] ENABLE TRIGGER [bustype_modified_date];
 GO

 ---Create trigger to update [modified_date] for [Bus].[BusRoute] table
 USE [PublicTransportation]
 GO
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TRIGGER [busroute_modified_date] on [Bus].[BusRoute] AFTER INSERT, UPDATE AS
 BEGIN
     UPDATE [Bus].[BusRoute]
     SET [modified_date] = CURRENT_TIMESTAMP
     FROM [Bus].[BusRoute] INNER JOIN inserted i ON [Bus].[BusRoute].[route_id] = i.[route_id]
 END;
 GO
 ALTER TABLE [Bus].[BusRoute] ENABLE TRIGGER [busroute_modified_date];
 GO

  ---Create trigger to update [modified_date] for [Bus].[BusInfo] table
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE TRIGGER [Bus].[businfo_modified_date] on [Bus].[BusInfo] AFTER INSERT, UPDATE AS
 BEGIN
     UPDATE [Bus].[BusInfo]
     SET [modified_date] = CURRENT_TIMESTAMP
     FROM [Bus].[BusInfo] INNER JOIN inserted i ON [Bus].[BusInfo].[bus_code] = i.[bus_code]
 END;
GO

ALTER TABLE [Bus].[BusInfo] ENABLE TRIGGER [businfo_modified_date];
GO

 ---Create trigger to update [modified_date] for [Bus].[BusTrip] table
 USE [PublicTransportation]
 GO
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TRIGGER [bustrip_modified_date] on [Bus].[BusTrip] AFTER INSERT, UPDATE AS
 BEGIN
     UPDATE [Bus].[BusTrip]
     SET [modified_date] = CURRENT_TIMESTAMP
     FROM [Bus].[BusTrip] INNER JOIN inserted i ON [Bus].[BusTrip].[trip_id] = i.[trip_id]
 END;
 GO
 ALTER TABLE [Bus].[BusTrip] ENABLE TRIGGER [bustrip_modified_date];
 GO

 ---Create trigger to backup objects with [dbo].[ChangeLog] table
USE [PublicTransportation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [backup_objects]
ON DATABASE
FOR CREATE_PROCEDURE, 
    ALTER_PROCEDURE, 
    DROP_PROCEDURE,
    CREATE_TABLE, 
    ALTER_TABLE, 
    DROP_TABLE,
    CREATE_FUNCTION, 
    ALTER_FUNCTION, 
    DROP_FUNCTION,
    CREATE_VIEW,
    ALTER_VIEW,
    DROP_VIEW
AS
 
SET NOCOUNT ON
 
DECLARE @data XML
SET @data = EVENTDATA()
 
INSERT INTO changelog(database_name, event_type, 
    object_name, object_type, sql_command, login_name)
VALUES(
@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'), 
@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)'), 
@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
);
GO
 
ENABLE TRIGGER [backup_objects] ON DATABASE;
GO