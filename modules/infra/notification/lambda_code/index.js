const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");
const ses = new SESClient({ region: process.env.SES_REGION });
exports.handler = async (event) => {
    const failures = [];
    for (const record of event.Records) {
        try {
            const body = JSON.parse(record.body);
            // 1. 수신자 이메일 주소 필수값 검증
            if (!body.to) {
                console.warn(`[Warning] No recipient email specified in message ID: ${record.messageId}`);
                continue;
            }
            // 2. 이메일 본문 구성 (HTML/Plain Text 모두 지원되도록 개선)
            const emailMessage = {
                Subject: { Data: body.subject || "[Team Train] 예매 완료 안내" },
                Body: {}
            };
            if (body.html) {
                emailMessage.Body.Html = { Data: body.html }; // 예매 내역 등 HTML 서식 지원
            }
            if (body.message) {
                emailMessage.Body.Text = { Data: body.message }; // Plain text 백업
            }
            // 3. SES 이메일 발송
            await ses.send(new SendEmailCommand({
                Source: process.env.SENDER_EMAIL,
                Destination: { ToAddresses: [body.to] },
                Message: emailMessage
            }));
            console.log(`[Success] Email sent successfully to ${body.to}`);
        } catch (error) {
            console.error(`[Error] Failed to process SQS message ID: ${record.messageId}`, error);
            // 실패한 메시지 ID를 수집하여 SQS에 부분 실패(partial batch failure)로 알림
            failures.push({ itemIdentifier: record.messageId });
        }
    }
    // 실패한 메시지만 SQS 큐에 남겨두어 재시도하게 처리
    return {
        batchItemFailures: failures
    };
};