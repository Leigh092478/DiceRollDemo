import configparser, json
import urllib3
import re

import logging

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
            stats = status + " - Please check the CloudWatch Log Stream for asg_configurator_lambda"
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


def handler(event, context):
    requestBody = event['body-json']

    print(event)
    # requestMessage = requestBody['text']
    # triggeredBy = requestBody['from']['name']

    # sendMSTeamsNotification(requestMessage, triggeredBy, "Successfull")

    # print(requestMessage)

    return json.dumps({
        'type': "String",
        'text': event
    })