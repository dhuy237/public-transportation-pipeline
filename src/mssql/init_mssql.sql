-- Set up Database
USE master ;  
GO  
CREATE DATABASE PublicTransportation  
ON   
( NAME = PT_dat,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ptdat.mdf',  
    SIZE = 10,  
    MAXSIZE = 50,  
    FILEGROWTH = 5 )  
LOG ON  
( NAME = PT_log,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ptlog.ldf',  
    SIZE = 5MB,  
    MAXSIZE = 25MB,  
    FILEGROWTH = 5MB ) ;  
GO  

-- Set up Schema
USE [PublicTransportation];
GO
CREATE SCHEMA Agency;
GO
CREATE SCHEMA Schedule;
GO

-- Create Table

-- Agency.Agency
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Agency].[Agency](
	[agency_id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[phone_number] [nvarchar](25) NOT NULL,
	[address] [nvarchar](200) NOT NULL,
	[operating_hour_start] [time](7) NOT NULL,
	[operating_hour_end] [time](7) NOT NULL,
 CONSTRAINT [PK_Agency] PRIMARY KEY CLUSTERED 
(
	[agency_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Agency.Bus
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Agency].[Bus](
	[bus_code] [int] NOT NULL,
	[route_id] [int] NOT NULL,
	[number_of_seat] [int] NOT NULL,
	[type] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Bus] PRIMARY KEY CLUSTERED 
(
	[bus_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Schedule.BusStop
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[BusStop](
	[bus_stop_id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[street] [nvarchar](100) NOT NULL,
	[district] [int] NOT NULL,
	[latitude] [float] NOT NULL,
	[longtitude] [float] NOT NULL,
 CONSTRAINT [PK_BusStop] PRIMARY KEY CLUSTERED 
(
	[bus_stop_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Schedule.Route
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[Route](
	[route_id] [int] NOT NULL,
	[agency_id] [int] NOT NULL,
	[route_name] [nvarchar](50) NOT NULL,
	[departure_name] [nvarchar](50) NOT NULL,
	[destination_name] [nvarchar](50) NOT NULL,
	[duration] [int] NOT NULL,
	[fare] [int] NOT NULL,
	[frequency] [int] NOT NULL,
	[number_of_stop] [int] NOT NULL,
	[number_of_bus] [int] NOT NULL,
	[operating_hour_start] [time](7) NOT NULL,
	[operating_hour_end] [time](7) NOT NULL,
	[distance] [int] NOT NULL,
 CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED 
(
	[route_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Schedule.StopRoute
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[StopRoute](
	[bus_stop_id] [int] NULL,
	[route_id] [int] NULL,
	[arrival_time] [time](7) NULL
) ON [PRIMARY]
GO

-- Schedule.StopTime
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[StopTime](
	[stop_time_id] [int] NOT NULL,
	[trip_id] [int] NOT NULL,
	[bus_stop_id] [int] NOT NULL,
 CONSTRAINT [PK_StopTime] PRIMARY KEY CLUSTERED 
(
	[stop_time_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Schedule.Trip
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[Trip](
	[trip_id] [int] NOT NULL,
	[bus_code] [int] NOT NULL,
	[trip_headsign] [nvarchar](150) NOT NULL,
    [date_stop] [date] NOT NULL,
	[time_stop] [time](7) NOT NULL,
	[number_of_ticket] [int] NOT NULL,
 CONSTRAINT [PK_Trip] PRIMARY KEY CLUSTERED 
(
	[trip_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Add primary and reference key
ALTER TABLE [Agency].[Bus]  WITH CHECK ADD  CONSTRAINT [FK_Bus_Route] FOREIGN KEY([route_id])
REFERENCES [Schedule].[Route] ([route_id])
GO
ALTER TABLE [Agency].[Bus] CHECK CONSTRAINT [FK_Bus_Route]
GO
ALTER TABLE [Schedule].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Agency] FOREIGN KEY([agency_id])
REFERENCES [Agency].[Agency] ([agency_id])
GO
ALTER TABLE [Schedule].[Route] CHECK CONSTRAINT [FK_Route_Agency]
GO
ALTER TABLE [Schedule].[StopRoute]  WITH CHECK ADD  CONSTRAINT [FK_StopRoute_BusStop] FOREIGN KEY([bus_stop_id])
REFERENCES [Schedule].[BusStop] ([bus_stop_id])
GO
ALTER TABLE [Schedule].[StopRoute] CHECK CONSTRAINT [FK_StopRoute_BusStop]
GO
ALTER TABLE [Schedule].[StopRoute]  WITH CHECK ADD  CONSTRAINT [FK_StopRoute_Route] FOREIGN KEY([route_id])
REFERENCES [Schedule].[Route] ([route_id])
GO
ALTER TABLE [Schedule].[StopRoute] CHECK CONSTRAINT [FK_StopRoute_Route]
GO
ALTER TABLE [Schedule].[StopTime]  WITH CHECK ADD  CONSTRAINT [FK_StopTime_BusStop] FOREIGN KEY([bus_stop_id])
REFERENCES [Schedule].[BusStop] ([bus_stop_id])
GO
ALTER TABLE [Schedule].[StopTime] CHECK CONSTRAINT [FK_StopTime_BusStop]
GO
ALTER TABLE [Schedule].[StopTime]  WITH CHECK ADD  CONSTRAINT [FK_StopTime_Trip] FOREIGN KEY([trip_id])
REFERENCES [Schedule].[Trip] ([trip_id])
GO
ALTER TABLE [Schedule].[StopTime] CHECK CONSTRAINT [FK_StopTime_Trip]
GO
ALTER TABLE [Schedule].[Trip]  WITH CHECK ADD  CONSTRAINT [FK_Trip_Bus] FOREIGN KEY([bus_code])
REFERENCES [Agency].[Bus] ([bus_code])
GO
ALTER TABLE [Schedule].[Trip] CHECK CONSTRAINT [FK_Trip_Bus]
GO
USE [master]
GO
ALTER DATABASE [PublicTransportation] SET  READ_WRITE 
GO

-- Create Agent Job / Schedule

-- Create Stored Procedure
