'''
Created on 10/24/2020
@author: lerionpg
'''

import configparser
import re


# Read the Config File
config = configparser.ConfigParser()
config.read('config.cfg')

def generatePolicy(principalId, effect, methodArn):
    print("****** Generating Policy *******")
    authResponse = {}
    authResponse['principalId'] = principalId
 
    if effect and methodArn:
        policyDocument = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Sid': 'FirstStatement',
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': methodArn
                }
            ]
        }
 
        authResponse['policyDocument'] = policyDocument
 
    return authResponse


def auth_handler(event, context):
    print(event)

    auth_referer = config['WHITELISTED_SENDER']['auth_referer']
    generatedPolicy = generatePolicy(None, 'Deny', event['methodArn'])

    try:
        print("***** request Authentication ******")
        
        authorizationToken = ""
        authorizedReferer = ""
        
        # for key, value in event["headers"].items():
        #     if key == "Authorization" or  key == "authorization":
        #         authorizationToken = value
        #
        #     if key == "Referer" or key == "referer":
        #         authorizedReferer = value
        #
        # if re.match(auth_referer, authorizedReferer) and authorizationToken is not None:
        #     generatedPolicy = generatePolicy(None, 'Allow', event['methodArn'])

        generatedPolicy = generatePolicy(None, 'Allow', event['methodArn'])

    except ValueError as err:
        # Deny access if the request param is invalid
        print(err)

    print(generatedPolicy)
    
    return generatedPolicy