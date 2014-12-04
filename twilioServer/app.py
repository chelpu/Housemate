from flask import Flask
from flask import request
from twilio.rest import TwilioRestClient
import os
app = Flask(__name__)

@app.route("/remind")
def remind():
    to_num = request.args.get('number', '')
    name = request.args.get('name', '')
    chore = request.args.get('chore', '')
    # twil_client = TwilioRestClient(os.environ['TWILIO_ACCOUNT_SID'], os.environ['TWILIO_AUTH_TOKEN'])
     
    print to_num
    print chore
    print name 

    # message = twil_client.messages.create(body="Hey, " + name + "! Could you please " + chore, to="+"+to_num, from_="+15005550006")
    print "Hey, " + name + "! Could you please " + chore + "?"
    return 'OK'

@app.route("/expenseRemind")
def expenseRemind():
    to_num = request.args.get('number', '')
    name = request.args.get('name', '')
    requesterName = request.args.get('requesterName', '')
    expense = request.args.get('expense', '')
    url = request.args.get('url', '')
    # twil_client = TwilioRestClient(os.environ['TWILIO_ACCOUNT_SID'], os.environ['TWILIO_AUTH_TOKEN'])
     
    print to_num
    print expense
    print name 

    # message = twil_client.messages.create(body="Hey, " + name + "! Could you please " + chore, to="+"+to_num, from_="+15005550006")
    print "Hey, " + name + "! Could you please pay " + requesterName + " for " + expense + "? Pay here: " + url
    return 'OK'

@app.route("/invite")
def invite():
    to_num = request.args.get('number', '')
    from_name = request.args.get('name', '')
    house_id = request.args.get('house_id', '')
    # twil_client = TwilioRestClient(os.environ['TWILIO_ACCOUNT_SID'], os.environ['TWILIO_AUTH_TOKEN'])
    
    # message = twil_client.messages.create(body=(from_name + " invited you to join a house on Housemate. To join, download the app and join the house with id: " + house_id), to="+"+to_num, from_="+15005550006")
    print from_name + " invited you to join a house on Housemate. To join, download the app and join the house with id: "
    print house_id 
    return 'OK'


if __name__ == '__main__':
    app.run()