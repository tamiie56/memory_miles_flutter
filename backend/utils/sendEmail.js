import nodemailer from "nodemailer"
import dns from "dns"

// IPv4 force
dns.setDefaultResultOrder("ipv4first")

const sendEmail = async ({ to, subject, html }) => {
    const transporter = nodemailer.createTransport({
        host: "smtp.gmail.com",
        port: 587,
        secure: false,
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS,
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