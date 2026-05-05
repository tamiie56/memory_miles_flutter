import nodemailer from "nodemailer"

const sendEmail = async ({ to, subject, html }) => {
    const transporter = nodemailer.createTransport({
        host: "smtp-mail.outlook.com",
        port: 587,
        secure: false,
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS,
        },
        tls: {
            ciphers: "SSLv3",
        },
    })

    await transporter.sendMail({
        from: `"Memory Miles" <${process.env.EMAIL_USER}>`,
        to,
        subject,
        html,
    })
}

export default sendEmail