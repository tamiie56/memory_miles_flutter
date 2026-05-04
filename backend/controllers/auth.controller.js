import bcryptjs from "bcryptjs"
import crypto from "crypto"
import User from "../models/user.model.js"
import { errorHandler } from "../utils/error.js"
import jwt from "jsonwebtoken"
import sendEmail from "../utils/sendEmail.js"

export const signup = async (req, res, next) => {
    const { username, email, password } = req.body

    if (!username || !email || !password || username === "" || email === "" || password === "") {
        return next(errorHandler(400, "All fields are required"))
    }

    const existingUser = await User.findOne({ email })
    if (existingUser) {
        return next(errorHandler(409, "User already exist with this email!"))
    }

    const hashedPassword = bcryptjs.hashSync(password, 10)
    const newUser = new User({ username, email, password: hashedPassword })

    try {
        await newUser.save()
        res.json("Signup successful")
    } catch (error) {
        next(error)
    }
}

export const signin = async (req, res, next) => {
    const { email, password } = req.body

    if (!email || !password || email === "" || password === "") {
        return next(errorHandler(400, "All fields are required"))
    }

    try {
        const validUser = await User.findOne({ email })
        if (!validUser) {
            return next(errorHandler(404, "User not found"))
        }

        const validPassword = bcryptjs.compareSync(password, validUser.password)
        if (!validPassword) {
            return next(errorHandler(400, "Wrong Credentials"))
        }

        const token = jwt.sign({ id: validUser._id }, process.env.JWT_SECRET)
        const { password: pass, ...rest } = validUser._doc

        res.status(200)
            .cookie("access_token", token, { httpOnly: true })
            .json({ ...rest, token })

    } catch (error) {
        next(error)
    }
}

// Send OTP to user email for password reset
export const forgotPassword = async (req, res, next) => {
    const { email } = req.body

    if (!email || email === "") {
        return next(errorHandler(400, "Email is required"))
    }

    try {
        const user = await User.findOne({ email })

        if (!user) {
            return next(errorHandler(404, "No account found with this email"))
        }

        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString()

        user.otp = otp
        user.otpExpires = Date.now() + 10 * 60 * 1000 // 10 minutes
        await user.save()

        // Send response first, then send email in background
        res.status(200).json({ message: "OTP sent successfully" })

        sendEmail({
            to: user.email,
            subject: "Memory Miles - Password Reset OTP",
            html: `
                <h2>Password Reset OTP</h2>
                <p>Use the following OTP to reset your password. It expires in <strong>10 minutes</strong>.</p>
                <h1 style="
                    font-size: 48px;
                    font-weight: bold;
                    color: #4f46e5;
                    letter-spacing: 8px;
                    text-align: center;
                    padding: 20px;
                    background: #f3f4f6;
                    border-radius: 8px;
                ">${otp}</h1>
                <p>If you did not request this, please ignore this email.</p>
            `,
        }).catch(err => console.error("Email send error:", err))

    } catch (error) {
        next(error)
    }
}

// Verify OTP
export const verifyOtp = async (req, res, next) => {
    const { email, otp } = req.body

    if (!email || !otp) {
        return next(errorHandler(400, "All fields are required"))
    }

    try {
        const user = await User.findOne({
            email,
            otp,
            otpExpires: { $gt: Date.now() },
        })

        if (!user) {
            return next(errorHandler(400, "Invalid or expired OTP"))
        }

        res.status(200).json({ message: "OTP verified successfully" })

    } catch (error) {
        next(error)
    }
}

// Reset password after OTP verification
export const resetPassword = async (req, res, next) => {
    const { email, otp, newPassword } = req.body

    if (!email || !otp || !newPassword) {
        return next(errorHandler(400, "All fields are required"))
    }

    try {
        const user = await User.findOne({
            email,
            otp,
            otpExpires: { $gt: Date.now() },
        })

        if (!user) {
            return next(errorHandler(400, "Invalid or expired OTP"))
        }

        user.password = bcryptjs.hashSync(newPassword, 10)
        user.otp = undefined
        user.otpExpires = undefined
        user.resetPasswordToken = undefined
        user.resetPasswordExpires = undefined

        await user.save()

        res.status(200).json({ message: "Password reset successful. You can now log in." })

    } catch (error) {
        next(error)
    }
}