BULK INSERT [Agency].[Agency]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\agency.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);

BULK INSERT [Agency].[Bus]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\bus.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);

BULK INSERT [Schedule].[BusStop]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\bus_stop.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);

BULK INSERT [Schedule].[Route]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\route.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);

BULK INSERT [Schedule].[StopRoute]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\stop_route.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);

BULK INSERT [Schedule].[StopTime]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\stop_time.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);

BULK INSERT [Schedule].[Trip]
FROM 'E:\fpt\training\Project 1\fa-project-1-team-7\resources\raw-folder\trip.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
);