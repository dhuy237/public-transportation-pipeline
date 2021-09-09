USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSPORT_WH;
USE DATABASE PUBLICTRANSPORTATION;
!set variable_substitution=true;
!define path='C:/Users/&{name}/project/buffer-folder/*.csv';
put file://&path @upload_stage;




