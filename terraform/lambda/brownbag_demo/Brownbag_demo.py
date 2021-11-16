import configparser, json
import urllib3
import re
import logging

import collections
import json
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Read the Config File
config = configparser.ConfigParser()
config.read('config.cfg')

http = urllib3.PoolManager()


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


def handler(event, context):
    requestBody = event['body-json']
    diceToRoll = event["number_of_dice"]
    diceSideMax = event["sides_of_dice"]
    maxRolledDice = event["roll_count"]

    print(event)

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
    # requestMessage = requestBody['text']
    # triggeredBy = requestBody['from']['name']

    #sendMSTeamsNotification(requestMessage, triggeredBy, "Successfull")

    #print(requestMessage)

    return json.dumps({
        'type': "String",
        'text': result
    })