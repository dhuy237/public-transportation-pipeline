USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSPORT_WH;
USE DATABASE PUBLICTRANSPORTATION;
!set variable_substitution=true;
!define path='C:/Users/&{name}/project/work-folder';
get @unload_stage file://&path;




