const https = require('https');
const zlib = require('zlib');

exports.handler = async (event) => {
    try {
        // CloudWatch Logs 페이로드는 Base64 인코딩 및 gzip 압축되어 전달됩니다.
        const payload = Buffer.from(event.awslogs.data, 'base64');
        const unzipped = zlib.gunzipSync(payload);
        const parsed = JSON.parse(unzipped.toString('utf8'));

        const logGroup = parsed.logGroup;
        const logEvents = parsed.logEvents;
        
        console.log(`Received ${logEvents.length} log events from ${logGroup}`);

        // 슬랙으로 보낼 메시지 구성
        for (const logEvent of logEvents) {
            const message = logEvent.message;
            const logTimestamp = new Date(logEvent.timestamp).toISOString();
            
            const slackMessage = {
                attachments: [
                    {
                        color: "#FF0000",
                        title: `🚨 [${process.env.ENVIRONMENT}] Application Error Detected`,
                        text: "백엔드 애플리케이션에서 에러 로그가 감지되었습니다.",
                        fields: [
                            {
                                title: "Log Group",
                                value: logGroup,
                                short: true
                            },
                            {
                                title: "Time",
                                value: logTimestamp,
                                short: true
                            },
                            {
                                title: "Error Message",
                                value: `\`\`\`${message.substring(0, 1000)}\`\`\``, // 슬랙 글자수 제한 대비
                                short: false
                            }
                        ]
                    }
                ]
            };

            await sendToSlack(slackMessage);
        }
        
        return { statusCode: 200, body: 'Successfully processed log events.' };
        
    } catch (error) {
        console.error("Error processing log events:", error);
        throw error;
    }
};

function sendToSlack(messageBody) {
    return new Promise((resolve, reject) => {
        const webhookUrl = process.env.SLACK_WEBHOOK_URL;
        if (!webhookUrl || webhookUrl === 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL') {
            console.log("Slack Webhook URL is not configured. Skipping slack notification.");
            return resolve();
        }

        const url = new URL(webhookUrl);
        const options = {
            hostname: url.hostname,
            path: url.pathname,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        };

        const req = https.request(options, (res) => {
            let responseBody = '';
            res.on('data', (chunk) => {
                responseBody += chunk;
            });
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(responseBody);
                } else {
                    reject(new Error(`Slack request failed with status ${res.statusCode}: ${responseBody}`));
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.write(JSON.stringify(messageBody));
        req.end();
    });
}
