# Configuration:
#   HUBOT_EMAIL_USER - The Gmail address from which to send emails.
#   HUBOT_EMAIL_PWD  - The password associated with the account.
#
# Commands:
#   hubot email <address@example.com> -s "<subject>" -m "<message>"
express = require "express"
nodemailer    = require "nodemailer"
smtpTransport = require('nodemailer-smtp-transport')
app = express()

smtpTransport = nodemailer.createTransport(smtpTransport(
  host: 'smtp.gmail.com',
  secureConnection: false,
  port: 587,
  auth:
    user: process.env.HUBOT_EMAIL_USER,
    pass: process.env.HUBOT_EMAIL_PWD))

module.exports = (robot) ->

  # Respond to an email command
  robot.respond ///
    email\s+ # The word email
    ([^\@]+\@[^\s]+) # An email address
    ( # Any amount of the following
      \s*\-s\s+(\')[^\']*(\') | # Single quoted subject line
      \s*\-s\s+(\")[^\"]*(\") | # Double quoted subject line
      \s*\-m\s+(\')[^\']*(\') | # Single quoted message line
      \s*\-m\s+(\")[^\"]*(\")   # Double quoted message line
    )+
  ///i, (msg) ->
    mailto  = msg.match[1]
    subject = msg.match[0].match(/\s*\-s\s+(\')[^\']*(\')|\s*\-s\s+(\")[^\"]*(\")/i)
    message = msg.match[0].match(/\s*\-m\s+(\')[^\']*(\')|\s*\-m\s+(\")[^\"]*(\")/i)
    if subject
      subject = subject[0].replace(/^\s*\-s\s*/g, '').trim().replace(/^(\'|\")|(\'|\")$/g, '')
    if message
      message = message[0].replace(/^\s*\-m\s*/g, '').trim().replace(/^(\'|\")|(\'|\")$/g, '')

    # Create an object to inform our mailing procedure
    obj = {
      from: "HUBOT <hubot@pratikpc.com>",
      to: mailto,
      subject: subject or "Just a friendly update from Factals"
      text: message or ""
    }

    if not message
      msg.send "I refuse to send an email with no message body."
    else
      if not smtpTransport
        msg.send "Mail is not currently initialized."
      else
        # send mail with defined transport object
        smtpTransport.sendMail obj, (error, response) ->
          if error 
            msg.send "There was an error: " + error
          else
            msg.send "Ok. I sent the email."