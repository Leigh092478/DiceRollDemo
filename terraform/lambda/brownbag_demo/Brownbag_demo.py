import configparser
import os
import urllib3
import re
import logging
import collections
import json
import random
import boto3
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Read the Config File
config = configparser.ConfigParser()
config.read('config.cfg')

# current date and time
now = datetime.now()
timestamp = str(int(datetime.now().timestamp()*1e3))

http = urllib3.PoolManager()

HTMLTAGPATTERNS = "copy-paste-block|div|<at>|</at>|&nbsp;|\n"

bucketURL = config['S3_BUCKET']['bucket_url']
bucketName = config['S3_BUCKET']['bucket_name']


def sendMSTeamsNotification(message, trigger, status):
    logger.info("Sending MS Teams Notification")

    try:
        URL = config['MS_TEAM_NOTIF_URL']['incoming_webhooks']

        trigger = "Triggered by : {}".format(trigger)

        stats = ""
        if re.search("Failed", status):
            stats = status + " - Please check the CloudWatch Log Stream"
        else:
            stats = status

        responseData = {
            "@type": "MessageCard",
            "@context": "http://schema.org/extensions",
            "themeColor": "0076D7",
            "summary": "BrownBag Session Demo - {}".format(status),
            "sections": [{
                "activityTitle": "BrownBag Session Demo - {}".format(status),
                "activitySubtitle": trigger,
                "activityImage": "https://teamsnodesample.azurewebsites.net/static/img/image9.png",
                "facts": [{
                    "name": "Message",
                    "value": message
                }, {
                    "name": "Status",
                    "value": stats
                }],
                "markdown": True
            }],
            "potentialAction": [{
                "@type": "ActionCard",
                "name": "Add a comment",
                "inputs": [{
                    "@type": "TextInput",
                    "id": "comment",
                    "isMultiline": False,
                    "title": "Add a comment here for this task"
                }],
                "actions": [{
                    "@type": "HttpPOST",
                    "name": "Add comment",
                    "target": "https://docs.microsoft.com/outlook/actionable-messages"
                }]
            }, {
                "@type": "ActionCard",
                "name": "Set due date",
                "inputs": [{
                    "@type": "DateInput",
                    "id": "dueDate",
                    "title": "Enter a due date for this task"
                }],
                "actions": [{
                    "@type": "HttpPOST",
                    "name": "Save",
                    "target": "https://docs.microsoft.com/outlook/actionable-messages"
                }]
            }]
        }

        data = json.dumps(responseData).encode('utf-8')

        response = http.request('POST', URL, body=data)

        if response.status != 200:
            logger.error("Sending MS Teams Notifications Failed : {}".format(response.status))
            logger.error(response.data)
    except Exception as error:
        logger.error("Failed Sending Notification - {}".format(error))


def getAWSClient(clientService):
    awsClient = None
    try:
        print("Establishing AWS {} Connection".format(clientService))
        awsClient = boto3.client(clientService)
    except AssertionError as error:
        print(error)

    return awsClient

def paramParser(params):
    patternTag = re.findall(HTMLTAGPATTERNS, params)

    if patternTag:
        if re.search("copy-paste-block", params):
            start = params.find("copy-paste-block") + len("copy-paste-block") + 2
            end = len(params)
            substring = params[start:end]
        else:
            substring = params

        for pat in patternTag:
            substring = substring.replace(pat, "")
    else:
        logger.error("No match")
        substring = params

    return substring


def rollDice(numberOfDice = 3, diceSideMax = 6, maxRoll = 100):
    diceSideMin = 1
    rollCount = 0

    sumRolledDiceList = []

    while maxRoll > rollCount:
        print("*** ROLLING : {} ***".format(rollCount))

        rolledDicesList = []
        minDices = 0
        while numberOfDice > minDices:
            rolledDicesList.append(random.randint(diceSideMin, diceSideMax))
            minDices += 1

        sumOfRolledDice = sum(rolledDicesList)
        sumRolledDiceList.append(sumOfRolledDice)
        resultSumList = collections.Counter(sumRolledDiceList)

        print("** ROLLED DICE : {}".format(rolledDicesList))
        print("** SUM OF ROLLED DICE : {}".format(sumOfRolledDice))
        rollCount += 1

    print("*** ROLLED DICE LIST : {}".format(sumRolledDiceList))

    return resultSumList


def getRequest(requestMessage):
    print("*** Retrieving Request Message ***")
    print(requestMessage)

    requestMessage = paramParser(requestMessage)

    requestMessage = requestMessage.split("ToolTest")
    request = requestMessage[1]

    requestPayloadList = set()

    if re.search(",", request):
        print("Parameters Found")
        payloadList = request.split(',')

        for payload in payloadList:
            payload = str(payload)
            if re.search("&nbsp;", payload):
                payload = payload.strip()

            load = payload.strip()
            if load is not None:
                requestPayloadList.add(load)

    print("*** REQUEST PAYLOAD LIST : {}".format(requestPayloadList))
    return requestPayloadList


def send2S3Bucket(s3Client, fileLocation):
    success = True

    try:
        filepath = '/tmp/'
        key = fileLocation[len(filepath):]

        with open(fileLocation, 'rb') as data:
            s3Client.upload_fileobj(data, bucketName, key)
    except Exception as error:
        success = False
        print(error)

    return success


def save2FileFolder(dumpPayload):
    # File Location and Naming
    filename = config['FILE']['fileName']
    fileExtension = config['FILE']['fileExtension']
    fileLocation = None
    fileFolderName = config['S3_BUCKET']['file_folder_name']

    demoToolFileName = filename + timestamp + "_" + fileExtension
    try:
        filepath = '/tmp/'
        folderName = filepath + fileFolderName

        if not os.path.exists(folderName):
            # create the folder
            os.mkdir(folderName)

        fileLocation = folderName + "/" + demoToolFileName

        f = open(fileLocation, "w")
        f.write(dumpPayload)
        f.close()
    except Exception as error:
        print(error)

    return fileLocation


def handler(event, context):
    print(" ****** EVENT : {}".format(event))

    s3Client = getAWSClient("s3")

    isMissingParams = False

    requestBody = event['body-json']
    requestMessage = requestBody['text']

    try:
        requestPayloadList = getRequest(requestMessage)

        if requestPayloadList is None:
            isMissingParams = True
        else:
            for requestPayload in requestPayloadList:
                print(requestPayload)
                req = requestPayload.split("=")
                if re.search("number", req[0]):
                    diceToRoll = int(req[1])
                    print("diceToRoll = {}".format(diceToRoll))
                elif re.search("sides", req[0]):
                    diceSideMax = int(req[1])
                    print("diceSideMax = {}".format(diceSideMax))
                elif re.search("max", req[0]):
                    maxRolledDice = int(req[1])
                    print("maxRolledDice = {}".format(maxRolledDice))

            rolled = rollDice(diceToRoll, diceSideMax, maxRolledDice)

            responseList = []
            for key in rolled.keys():
                resultResponse = {
                    "sumOccurence": rolled[key],
                    "rolledDicesSum": key
                }
                responseList.append(resultResponse)

            result = {
                "NumberOfDices": diceToRoll,
                "DiceRolledCount": maxRolledDice,
                "SidesOfRolledDices": diceSideMax,
                "DicesRolledResult": responseList,
                "Raw": rolled
            }

            print(result)

            result = json.dumps(result)

            # Save the Result in S3
            if s3Client is not None:
                fileLocation = save2FileFolder(result)
                print(fileLocation)

                if fileLocation is not None:
                    saved2S3 = send2S3Bucket(s3Client, fileLocation)
                    print(saved2S3)

    except Exception as error:
        print(error)
        isMissingParams = True
        print("Exception Error, Parameters Missing - {}".format(requestMessage))

    if bool(isMissingParams):
        return json.dumps({
            'type': "String",
            'text': "Missing parameters invoking AWS Lambda Test Toll."
        })
    else:
        return json.dumps({
            'type': "String",
            'text': result
        })
