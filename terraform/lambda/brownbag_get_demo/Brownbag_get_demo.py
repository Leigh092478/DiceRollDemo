import configparser, json
import os

import urllib3
import re
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Read the Config File
config = configparser.ConfigParser()
config.read('config.cfg')

http = urllib3.PoolManager()

bucketURL = config['S3_BUCKET']['bucket_url']
bucketName = config['S3_BUCKET']['bucket_name']


def getAWSClient(clientService):
    awsClient = None
    try:
        print("Establishing AWS {} Connection".format(clientService))
        awsClient = boto3.client(clientService)
    except AssertionError as error:
        print(error)

    return awsClient


def percentage(sumOccurence, totalRollCount):
  percentage = 100 * float(sumOccurence)/float(totalRollCount)
  return str(percentage) + "%"


def handler(event, context):
    print(event)

    # get all the files in s3 buckets
    s3Client = getAWSClient("s3")
    fileFolderName = config['S3_BUCKET']['file_folder_name']

    filepath = '/tmp/'
    folderName = filepath + fileFolderName

    if not os.path.exists(folderName):
        # create the folder
        os.mkdir(folderName)

    # Get the total number of simulations
    bucketFolderFile = s3Client.list_objects(Bucket = bucketName)['Contents']

    # for every single file it is equal to a single similation with multiple roll
    simulationRequestRollCounter = 0
    totalDiceRolledCounter = 0

    allDataSet = []

    for bucketObj in bucketFolderFile:
        bucketKey = bucketObj['Key']

        if not bucketKey.endswith('/'):
            simulationRequestRollCounter += 1
            print("** KeyName {} : ".format(bucketKey))
            fileLocation = filepath + bucketKey
            open(fileLocation, "w")
            s3Client.download_file(bucketName, bucketKey, fileLocation)

            data = None
            dataSet = None
            with open(fileLocation) as file:
                data = json.load(file)

            if data is not None:
                sidesOfRolledDices = int(data["SidesOfRolledDices"])
                print("*** Side Of Dice : {}".format(sidesOfRolledDices))
                diceRolledCount = int(data["DiceRolledCount"])
                totalDiceRolledCounter += diceRolledCount

                resultSet = []
                diceRolledResultList = data["DicesRolledResult"]
                for rolledResult in diceRolledResultList:
                    sumOccurence = int(rolledResult["sumOccurence"])
                    rolledDicesSum = int(rolledResult["rolledDicesSum"])

                    # Calculate the Percentage
                    relativeDistribution = percentage(sumOccurence, diceRolledCount)

                    rolledResultDistribution = {
                        "sumOccurence": sumOccurence,
                        "rolledDicesSum": rolledDicesSum,
                        "relativeDistribution" : relativeDistribution
                    }

                    resultSet.append(rolledResultDistribution)

                dataSet = {
                    "SidesOfRolledDices" : sidesOfRolledDices,
                    "DataDistribution" : resultSet
                }
                print(dataSet)

            allDataSet.append(dataSet)

    dataGathered = {
        "Simulation_Request" : simulationRequestRollCounter,
        "Total_Dice_Rolled" : totalDiceRolledCounter,
        "DataGathered" : allDataSet
    }

    print(dataGathered)

    return json.dumps({
        'type': "String",
        'text': "TEST"
    })