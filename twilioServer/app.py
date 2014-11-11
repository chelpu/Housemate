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
    twil_client = TwilioRestClient(os.environ['TWILIO_ACCOUNT_SID'], os.environ['TWILIO_AUTH_TOKEN'])
     
    print to_num
    print chore
    print name 

    # message = twil_client.messages.create(body="Hey, " + name + "! Could you please " + chore, to="+"+to_num, from_="+15005550006")
    print "Hey, " + name + "! Could you please " + chore + "?"
    return 'OK'

if __name__ == '__main__':
    app.run()