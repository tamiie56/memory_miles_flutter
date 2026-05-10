import nodemailer from "nodemailer"
import { Resend } from "resend"

const sendEmail = async ({ to, subject, html }) => {
    // Production: use Resend
    if (process.env.RESEND_API_KEY) {
        const resend = new Resend(process.env.RESEND_API_KEY)
        await resend.emails.send({
            from: "Memory Miles <onboarding@resend.dev>",
            to,
            subject,
            html,
        })
        return
    }

    // Local development: use Nodemailer Gmail
    const transporter = nodemailer.createTransport({
        service: "gmail",
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