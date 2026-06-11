const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

const ses = new SESClient({ region: process.env.SES_REGION });

exports.handler = async (event) => {
    for (const record of event.Records) {
        const body = JSON.parse(record.body);

        await ses.send(new SendEmailCommand({
            Source: process.env.SENDER_EMAIL,
            Destination: { ToAddresses: [body.to] },
            Message: {
                Subject: { Data: body.subject || "알림" },
                Body: { Text: { Data: body.message || "" } }
            }
        }));
    }
};
