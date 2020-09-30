import boto3

client = boto3.client('ec2')

def lambda_handler(event, context):
    #instance must not be on "terminated" state and with the tagg 'cleanup'
    Rinstances = client.describe_instances(Filters=[{'Name': 'tag-key', 'Values': ['cleanup']}])
    
    for r in Rinstances['Reservations']:
      for i_desc in r['Instances']:
          instance_id =(i_desc['InstanceId'])
          #print(i_desc['InstanceId'],i_desc['State']['Name'])
          print(instance_id ,i_desc['State']['Name'])
      
          # Stop the instance
          stoppingInstances = client.stop_instances(InstanceIds=[instance_id])
          waiter=client.get_waiter('instance_stopped')
          waiter.wait(InstanceIds=[instance_id])
          print(stoppingInstances)
