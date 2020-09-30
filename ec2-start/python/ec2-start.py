import boto3

client = boto3.client('ec2')

def lambda_handler(event, context):
    #instance must not be on "terminated" state and with the tagg 'wakeup'
    Rinstances = client.describe_instances(Filters=[{'Name': 'tag-key', 'Values': ['wakeup']}])
    
    for r in Rinstances['Reservations']:
      for i_desc in r['Instances']:
          instance_id =(i_desc['InstanceId'])
          #print(i_desc['InstanceId'],i_desc['State']['Name'])
          print("Previous state:")
          print(instance_id ,i_desc['State']['Name'])
      
          # Start the instance
          startInstances = client.start_instances(InstanceIds=[instance_id])
          print(f"Starting the Instance: {startInstances}")
