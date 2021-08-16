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

SRA_PATH = 'C:\\Users\\Huy\\ssh_temp\\rsa_key.p8'
LOG_PATH = 'E:\\fpt\\training\\Project 1\\fa-project-1-team-7\\resources\\logs\\ingest.log'

ACCOUNT = 'qn37920.southeast-asia.azure'
HOST = 'qn37920.southeast-asia.azure.snowflakecomputing.com'
USER = 'dhuy237'

BUS_PIPE = 'publictransportation.public.bus_pipe'
ROUTE_PIPE = 'publictransportation.public.route_pipe'
BUSSTOP_PIPE = 'publictransportation.public.busstop_pipe'
TRIP_PIPE = 'publictransportation.public.trip_pipe'
STOPROUTE_PIPE = 'publictransportation.public.stoproute_pipe'
STOPTIME_PIPE = 'publictransportation.public.stoptime_pipe'

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


logging.basicConfig(
        filename=LOG_PATH,
        level=logging.DEBUG)
logger = getLogger(__name__)

with open(SRA_PATH, 'rb') as pem_in:
    pemlines = pem_in.read()
    private_key_obj = load_pem_private_key(pemlines,
    get_private_key_passphrase().encode(),
    default_backend())
    
private_key_text = private_key_obj.private_bytes(
  Encoding.PEM, PrivateFormat.PKCS8, NoEncryption()).decode('utf-8')
# Assume the public key has been registered in Snowflake:
# private key in PEM format

loadData(['bus_sf.csv.gz'], BUS_PIPE)
loadData(['route_sf.csv.gz'], ROUTE_PIPE)
loadData(['bus_stop_sf.csv.gz'], BUSSTOP_PIPE)
loadData(['trip_sf.csv.gz'], TRIP_PIPE)
loadData(['stop_route_sf.csv.gz'], STOPROUTE_PIPE)
loadData(['stop_time_sf.csv.gz'], STOPTIME_PIPE)