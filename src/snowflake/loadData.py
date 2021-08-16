from logging import getLogger
from snowflake.ingest import SimpleIngestManager
from snowflake.ingest import StagedFile
from snowflake.ingest.utils.uris import DEFAULT_SCHEME
from datetime import timedelta
from requests import HTTPError
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.hazmat.primitives.serialization import PrivateFormat
from cryptography.hazmat.primitives.serialization import NoEncryption
import time
import datetime
import os
import logging

ACCOUNT = 'qn37920.southeast-asia.azure'
HOST = 'qn37920.southeast-asia.azure.snowflakecomputing.com'
USER = 'dhuy237'

BUS_PIPE = 'publictransportation.public.bus_pipe'
ROUTE_PIPE = 'publictransportation.public.route_pipe'
BUSSTOP_PIPE = 'publictransportation.public.busstop_pipe'
TRIP_PIPE = 'publictransportation.public.trip_pipe'
STOPROUTE_PIPE = 'publictransportation.public.stoproute_pipe'
STOPTIME_PIPE = 'publictransportation.public.stoptime_pipe'

logging.basicConfig(
        filename='E:\\fpt\\training\\Project 1\\example\\test_snowflake_log\\ingest.log',
        level=logging.DEBUG)
logger = getLogger(__name__)

# If you generated an encrypted private key, implement this method to return
# the passphrase for decrypting your private key.
def get_private_key_passphrase():
  return '12345'

def loadData(file_list, pipe):
    ingest_manager = SimpleIngestManager(account=ACCOUNT,
                                        host=HOST,
                                        user=USER,
                                        pipe=pipe,
                                        private_key=private_key_text)
    # List of files, but wrapped into a class
    staged_file_list = []
    for file_name in file_list:
        staged_file_list.append(StagedFile(file_name, None))

    try:
        resp = ingest_manager.ingest_files(staged_file_list)
    except HTTPError as e:
        # HTTP error, may need to retry
        logger.error(e)
        exit(1)

    # This means Snowflake has received file and will start loading
    assert(resp['responseCode'] == 'SUCCESS')

    while True:
        history_resp = ingest_manager.get_history()

        if len(history_resp['files']) > 0:
            print('Ingest Report:\n')
            print(history_resp)
            break
        else:
            # wait for 20 seconds
            time.sleep(20)

        hour = timedelta(hours=1)
        date = datetime.datetime.utcnow() - hour
        history_range_resp = ingest_manager.get_history_range(date.isoformat() + 'Z')

        print('\nHistory scan report: \n')
        print(history_range_resp) 


with open("C:\\Users\\Huy\\ssh_temp\\rsa_key.p8", 'rb') as pem_in:
  pemlines = pem_in.read()
  private_key_obj = load_pem_private_key(pemlines,
  get_private_key_passphrase().encode(),
  default_backend())

private_key_text = private_key_obj.private_bytes(
  Encoding.PEM, PrivateFormat.PKCS8, NoEncryption()).decode('utf-8')
# Assume the public key has been registered in Snowflake:
# private key in PEM format

# List of files in the stage specified in the pipe definition
# bus_file_list=['trip_sf.csv.gz']
# bus_ingest_manager = SimpleIngestManager(account=ACCOUNT,
#                                      host=HOST,
#                                      user=USER,
#                                      pipe=TRIP_PIPE,
#                                      private_key=private_key_text)
# # List of files, but wrapped into a class
# staged_file_list = []
# for file_name in bus_file_list:
#     staged_file_list.append(StagedFile(file_name, None))

# try:
#     bus_resp = bus_ingest_manager.ingest_files(staged_file_list)
# except HTTPError as e:
#     # HTTP error, may need to retry
#     logger.error(e)
#     exit(1)

# # This means Snowflake has received file and will start loading
# assert(bus_resp['responseCode'] == 'SUCCESS')

# # Needs to wait for a while to get result in history
# while True:
#     history_resp = bus_ingest_manager.get_history()

#     if len(history_resp['files']) > 0:
#         print('Ingest Report:\n')
#         print(history_resp)
#         break
#     else:
#         # wait for 20 seconds
#         time.sleep(20)

#     hour = timedelta(hours=1)
#     date = datetime.datetime.utcnow() - hour
#     history_range_resp = bus_ingest_manager.get_history_range(date.isoformat() + 'Z')

#     print('\nHistory scan report: \n')
#     print(history_range_resp) 

# loadData(['bus_sf.csv.gz'], BUS_PIPE)
# loadData(['route_sf.csv.gz'], ROUTE_PIPE)
# loadData(['bus_stop_sf.csv.gz'], BUSSTOP_PIPE)
loadData(['trip_sf.csv.gz'], TRIP_PIPE)
# loadData(['stop_route_sf.csv.gz'], STOPROUTE_PIPE)
# loadData(['stop_time_sf.csv.gz'], STOPTIME_PIPE)