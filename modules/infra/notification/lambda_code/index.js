const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

// 🟢 AWS SDK SES Client 초기화 (Lambda 런타임에 내장된 SDK v3 사용)
const ses = new SESClient({ region: process.env.SES_REGION || "ap-northeast-2" });

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

            // 2. 이메일 발송 옵션 설정 (인증된 발신자 도메인/이메일 사용)
            const senderEmail = process.env.SENDER_EMAIL || "no-reply@team-train.cloud";
            
            const params = {
                Source: `"Team Train" <${senderEmail}>`,
                Destination: {
                    ToAddresses: [body.to]
                },
                Message: {
                    Subject: {
                        Data: body.subject || "[Team Train] 예매 완료 안내",
                        Charset: "UTF-8"
                    },
                    Body: {
                        Html: {
                            Data: body.html || body.message || "",
                            Charset: "UTF-8"
                        }
                    }
                }
            };

            // 3. AWS SES를 이용한 이메일 발송
            const command = new SendEmailCommand(params);
            const info = await ses.send(command);
            console.log(`[Success] Email sent successfully via SES to ${body.to} (MessageId: ${info.MessageId})`);
            
        } catch (error) {
            console.error(`[Error] Failed to process SQS message ID: ${record.messageId}`, error);
            // 실패 시 SQS 부분 실패(partial batch failure) 배열에 추가
            failures.push({ itemIdentifier: record.messageId });
        }
    }
    
    // 실패한 메시지만 SQS 큐에 남겨두어 백엔드/워커 단에서 재시도할 수 있게 복귀 처리
    return {
        batchItemFailures: failures
    };
}