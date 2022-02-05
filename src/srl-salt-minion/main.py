#!/usr/bin/env python
# coding=utf-8

import grpc, socket, json, sys, os

from datetime import datetime

from sdk_protos  import sdk_service_pb2,sdk_service_pb2_grpc,config_service_pb2

import logging
from logging.handlers import RotatingFileHandler

agent_name = "srl_salt_minion"

##################################################################
## Proc to process the config Notifications received by agent
## Processing config from js_path = .<agent_name>
##################################################################
def Handle_Notification(obj):
  if obj.HasField('config'):
    logging.info(f"Got config for agent, now will handle it :: \n{obj.config}\
                   Operation :: {obj.config.op}\nData :: {obj.config.data.json}")
    if obj.config.op == 2:
      logging.info("TODO - delete config scenario")
      # response=stub.AgentUnRegister(request=sdk_service_pb2.AgentRegistrationRequest(), metadata=metadata)
      # logging.info('Handle_Config: Unregister response:: {}'.format(response))
    else:
      json_acceptable_string = obj.config.data.json.replace("'", "\"")
      data = json.loads(json_acceptable_string)
      logging.info( data )

      # import threading
      # threading.Thread( target=Connect_To_Master, args=( data["master"]["value"], ) ).start()
      # Need to use the main thread
      if 'master' in data:
         Connect_To_Master( data["master"]["value"] )

def Connect_To_Master(address):

  # Salt specific
  from salt.minion import Minion
  from salt.config import DEFAULT_MINION_OPTS

  UUIDs = {
   'srl1': '8f7d68e2-30c5-40c6-b84a-df7e978a03ee',
   'srl2': '1d3c5473-1fbc-479e-b0c7-877705a0730f'
  }
  hostname = socket.gethostname()

  opts = { **DEFAULT_MINION_OPTS,
           'master': address, # "172.20.20.10"
           'id': hostname,
           'autosign_grains': ['id','uuid'],
           '__role': 'minion',
           'uuid': UUIDs[hostname] if hostname in UUIDs else '?',
           'enable_fqdns_grains': False, # No DNS available
           'log_level': 'debug', 'log_level_logfile': 'debug',
           # 'root_dir': os.environ['PWD']
         }
  try:
    import subprocess
    ip_route = subprocess.check_output(['ip','route'])
    logging.info( f"Minion {hostname}({opts['uuid']}) connecting to master at {address}: \n{ip_route}" )
    m = Minion( opts=opts )
    m.sync_connect_master()
    logging.info( f"Minion {hostname} connected to master" )
  except Exception as ex:
    logging.error(ex)
    sys.exit( -1 )

if __name__ == "__main__":

    log_filename = f"/var/log/srlinux/stdout/{agent_name}.log"
    logging.basicConfig(
        handlers=[RotatingFileHandler(log_filename, maxBytes=3000000, backupCount=5)],
        format="%(asctime)s,%(msecs)03d %(name)s %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
        level=logging.INFO,
    )
    logging.info("START TIME :: {}".format(datetime.now()))

    # while not os.path.exists('/var/run/netns/srbase-mgmt'):
    #  logging.info("Waiting for srbase-mgmt netns to be created...")
    #  time.sleep(1)

    channel = grpc.insecure_channel("127.0.0.1:50053")
    metadata = [("agent_name", agent_name)]
    sdk_mgr_client = sdk_service_pb2_grpc.SdkMgrServiceStub(channel)

    response = sdk_mgr_client.AgentRegister(
        request=sdk_service_pb2.AgentRegistrationRequest(), metadata=metadata
    )
    logging.info(f"Agent succesfully registered! App ID: {response.app_id}")

    # Subscribe to configuration events
    request=sdk_service_pb2.NotificationRegisterRequest(op=sdk_service_pb2.NotificationRegisterRequest.Create)
    create_subscription_response = sdk_mgr_client.NotificationRegister(request=request, metadata=metadata)
    stream_id = create_subscription_response.stream_id
    logging.info(f"Create subscription response received. stream_id : {stream_id}")

    cfgsubreq = config_service_pb2.ConfigSubscriptionRequest()
    request = sdk_service_pb2.NotificationRegisterRequest(
     op=sdk_service_pb2.NotificationRegisterRequest.AddSubscription,
     stream_id=stream_id, config=cfgsubreq)
    subscription_response = sdk_mgr_client.NotificationRegister(request=request, metadata=metadata)

    stream_request = sdk_service_pb2.NotificationStreamRequest(stream_id=stream_id)
    sub_stub = sdk_service_pb2_grpc.SdkNotificationServiceStub(channel)
    stream_response = sub_stub.NotificationStream(stream_request, metadata=metadata)

    try:
      # Blocking call to wait for events
      for r in stream_response:
        logging.info(f"NOTIFICATION:: \n{r.notification}")
        for obj in r.notification:
            if obj.HasField('config') and obj.config.key.js_path == ".commit.end":
                logging.info('TO DO -commit.end config')
            else:
                Handle_Notification(obj)
    except Exception as ex:
      logging.error( ex )

    logging.info( "SRL Salt minion agent exiting..." )
