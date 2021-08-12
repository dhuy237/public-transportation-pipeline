put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/bus_stop.csv' @example_db.schedule.%busstop;
put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/agency.csv' @example_db.agency.%agency;
put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/bus.csv' @example_db.agency.%bus;
put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/route.csv' @example_db.schedule.%route;
put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/stop_route.csv' @example_db.schedule.%stoproute;
put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/stop_time.csv' @example_db.schedule.%stoptime;
put 'file://E:/fpt/training/Project 1/fa-project-1-team-7/resources/work-folder/trip.csv' @example_db.schedule.%trip;

copy into example_db.schedule.busstop
from @example_db.schedule.%busstop
files = ('bus_stop.csv.gz')
file_format = (type = csv skip_header = 1);

copy into example_db.agency.agency
from @example_db.agency.%agency
files = ('agency.csv.gz')
file_format = (type = csv skip_header = 1);

copy into example_db.agency.bus
from @example_db.agency.%bus
files = ('bus.csv.gz')
file_format = (type = csv skip_header = 1);

copy into example_db.schedule.route
from @example_db.schedule.%route
files = ('route.csv.gz')
file_format = (type = csv skip_header = 1);

copy into example_db.schedule.stoproute
from @example_db.schedule.%stoproute
files = ('stop_route.csv.gz')
file_format = (type = csv skip_header = 1);

copy into example_db.schedule.stoptime
from @example_db.schedule.%stoptime
files = ('stop_time.csv.gz')
file_format = (type = csv skip_header = 1);

copy into example_db.schedule.trip
from @example_db.schedule.%trip
files = ('trip.csv.gz')
file_format = (type = csv skip_header = 1);