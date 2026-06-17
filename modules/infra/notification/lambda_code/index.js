const nodemailer = require('nodemailer');

// 🟢 범용 SMTP 인스턴스 초기화 (호스트, 포트 설정을 통해 네이버/다음/구글 모두 지원)
const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,                        
    port: parseInt(process.env.SMTP_PORT, 10) || 465,   // SSL/TLS 보안 포트 (기본값 465)
    secure: process.env.SMTP_SECURE === 'true',         
    auth: {
        user: process.env.SMTP_USER,                    
        pass: process.env.SMTP_PASS                    
    }
});

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

            // 2. 이메일 본문 구성
            const mailOptions = {
                from: `"Team Train" <${process.env.SMTP_USER}>`, 
                to: body.to,
                subject: body.subject || "[Team Train] 예매 완료 안내",
                text: body.message || "",                
                html: body.html || ""                   
            };

            // 3. 외부 SMTP 엔진을 이용한 이메일 발송
            const info = await transporter.sendMail(mailOptions);
            console.log(`[Success] Email sent successfully via SMTP to ${body.to} (MsgID: ${info.messageId})`);
            
        } catch (error) {
            console.error(`[Error] Failed to process SQS message ID: ${record.messageId}`, error);
            // 기존의 안전한 아키텍처 유지: 실패 시 SQS 부분 실패(partial batch failure) 배열에 추가
            failures.push({ itemIdentifier: record.messageId });
        }
    }
    
    // 실패한 메시지만 SQS 큐에 남겨두어 백엔드/워커 단에서 재시도할 수 있게 복귀 처리
    return {
        batchItemFailures: failures
    };
};